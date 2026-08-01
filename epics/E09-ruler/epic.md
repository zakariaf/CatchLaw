# E09 — Ruler and calibration

| | |
|---|---|
| **Branch** | `epic/09-ruler` |
| **After** | E07 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §4.2, §6 S3 and S4, §9.3 (the ruler does not mirror), §9.5 (units), §11 Both (landscape on S3), §13 (targets), §16 R3 |
| **Package** | `app/` — `app/lib/ui/ruler/`, `app/lib/domain/models/`, `app/lib/data/repositories/` |

## What this epic achieves

When this merges a fisher can measure a fish. Two paths exist and both end in an integer of
millimetres carrying its measurement method: a one-time calibration against the bank card in his
pocket (S4) which turns the screen into a physical scale (S3), and a numeric keypad that works on a
device that has never been calibrated. Step-and-mark lets a fish longer than the phone be walked
along the scale in up to four segments with a running total and a cancel that restores what was
already saved. The ruler is pinned `TextDirection.ltr` in all six locales while its labels localise
their numerals, so zero sits at the snout in Arabic exactly as it does in Galician. E10 can now take
a `Measurement` and hand it to the engine; E13 can persist one on a catch; E16 can offer
recalibration from Settings.

It also produces the first evidence for `SPEC.md` §16 R3. The accuracy harness (T08) and the device
matrix it fills in are the difference between "±1.5 mm over 15 cm" being a claim and being a
measurement.

## Where we are now

The branch is cut from a `main` that contains E01–E07.

- **E01** — the pub workspace (D-1), `analysis_options.yaml`, and every §14 static gate wired into CI.
- **E02, E03** — `packages/rule_engine/`: normalisation, the §7.3 resolution algorithm, sealed
  `Verdict`/`Finding`, the required `Citation`, and the `MeasurementMethod` enum plus the
  `Measurement` value type the engine compares against a rule row. **E09 consumes those types and
  does not redefine them** (D-7: the engine owns the types, the app owns the words).
- **E04** — `tools/content_builder/` and the Galicia seed, including `rule.measurement_method_id`.
- **E05** — both drift databases. `user.db` already carries `user_profile.ruler_px_per_mm REAL` and
  `user_profile.ruler_calibrated_at TEXT` and `user_profile.length_unit TEXT` (`SPEC.md` §7.2);
  E09 writes those three columns and adds no schema.
- **E06** — six ARB files (D-3), the `content_string` fallback chain, and the numeral-system lever
  (`numberFormatSymbols`, `SPEC.md` §9.3) swapped at bootstrap from `user_profile.numeral_system`.
- **E07** — `app/lib/theme/` (D-2): `LonjaTokens`, the three hand-authored themes, the glove density
  set, the type ramp. Whether E07 also published the shared `LonjaKeypad` control under
  `app/lib/ui/core/ui/` is not knowable from here; T06 states what to do in either case.

**E08 may or may not be merged when this branch is cut** — README puts both epics after E07. Nothing
in E09 may import anything E08 delivers. The ruler receives its species, its rule row and its
measurement method as parameters; wiring them to S2 is E10's task.

There is no ruler, no calibration row is ever written, and `user_profile.ruler_px_per_mm` is always
NULL. Manual length entry does not exist either, so today the app cannot produce a length at all.

## Why this epic exists here in the order

It cannot come earlier: the ruler is painted with `LonjaTokens` snapshots (E07) and reads its tick
labels through the locale's `NumberFormat` (E06), and every reading is persisted through the
`user_profile` row E05 created. It must not come later: `SPEC.md` §15 step 8 makes the result screen
depend on step 7, and E10 cannot render "38 cm, minimum 45 cm (total length)" until something
produces the 38. `SPEC.md` §15 step 7 also carries an instruction this epic honours literally —
*"validate against a printed scale on three physical devices before proceeding"* — which is why T08
is inside this epic and not deferred to E21.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The calibration model | `T01-calibration-model.md` | M | — |
| T02 | S4 — calibration, with a verify step | `T02-calibration-screen-with-verify.md` | L | T01 |
| T03 | `RulerPainter` | `T03-ruler-painter.md` | L | T01 |
| T04 | The deliberate LTR exception | `T04-ltr-exception.md` | M | T03 |
| T05 | Step and mark | `T05-step-and-mark.md` | M | T04 |
| T06 | Manual entry, before any calibration exists | `T06-manual-entry-before-calibration.md` | M | T05 |
| T07 | Landscape, and millimetres as the only stored unit | `T07-landscape-and-millimetres.md` | M | T05, T06 |
| T08 | The accuracy harness and the paints tests | `T08-accuracy-harness-and-paints-tests.md` | L | T03, T07 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable at the epic level:

- [ ] All 8 tasks committed, one commit each, every `Task: E09/Tnn` trailer present.
- [ ] `cd app && flutter test` green; `flutter analyze` and `dart format --set-exit-if-changed .` clean.
- [ ] `check_measurement.sh app/lib`, `check_lonja_tokens.sh app/lib`,
      `check_lonja_controls.sh app/lib` and `check_app_invariants.sh app/lib` all clean, each against
      a directory that is verifiably non-empty (`CONVENTIONS.md` §7).
- [ ] No `double` or `String` length field exists anywhere in `app/lib`; `pxPerMm` is the only
      `double` in the subsystem and it is a scale factor, not a length.
- [ ] A widget test completes a measurement by keypad alone with `ruler_px_per_mm` NULL — the §14
      "manual length entry before ever calibrating" line is executable, not manual.
- [ ] An `ar` test asserts zero sits at the same physical edge as in `en`, and an `ar` golden shows
      tick numerals in the numeral system the resolved locale selects.
- [ ] `RulerPainter` contains no `BuildContext`, no `Theme.of`, no `LonjaTokens.of`, no
      `Directionality`, no `Matrix4.rotationY` — proved by check 8 of `check_lonja_tokens.sh` and
      check 3 of `check_measurement.sh`.
- [ ] The device accuracy matrix in
      `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` has at least
      three real rows, median absolute error ≤ 1.5 mm over 150 mm and no device above 3.0 mm.
- [ ] All six ARB files gained the same keys (D-3); no ARB value contains a banned imperative —
      note that **`Return` is in the banned lexicon**, so no control may be labelled "Return".
- [ ] PR checks all SUCCESS; merged with `gh pr merge --squash --admin --delete-branch` (D-9).

## Risks and the things that will bite

1. **The ±1.5 mm target is unproven and this epic is where it stops being a claim.** `SPEC.md` §16 R3
   sets median absolute error ≤ 1.5 mm over 150 mm with no device worse than 3.0 mm, measured on six
   phones, ten readings each, against a printed 300 mm engineering scale. Nothing in a widget test
   can produce that number. T08 delivers the harness and the protocol; the matrix rows are field
   work. `catchlaw-measurement-ruler/references/ruler-and-calibration.md` states the consequence
   plainly and this epic adopts it: *a release with an empty matrix does not ship the ruler tab*, and
   manual entry alone is a complete, honest product.

2. **An ID-1 card does not fit across a phone in portrait.** 85.60 mm at the nominal 6.299 logical
   px/mm is **539 logical px**; the widest current phone is ~412 dp wide in portrait, and even at
   the plausibility floor of 4.50 px/mm the card is 385 px. Calibration is therefore a landscape
   procedure on every phone, which is why S4 shares S3's landscape allowance (`SPEC.md` §11 Both).
   A device whose longest edge is under 539 px falls into the skill's documented
   *screen smaller than the card* row: the ruler tab is disabled with a one-line reason and manual
   entry stays live.

3. **Four segments of screen do not reach a Kanaad.** `SPEC.md` §4.2 caps step-and-mark at four
   segments. A 915 dp landscape span at 6.299 px/mm is ~145 mm, so four segments reach ~580 mm —
   short of the 650 mm fork-length minimum for *Scomberomorus commerson* in AE-RK. For the large
   pelagics the keypad is not a fallback, it is the path. T06 is therefore load-bearing, and T05
   states the ceiling in the UI rather than letting a fisher discover it mid-fish.

4. **Two published target sizes, and this epic must not pick a third.**
   `lonja-design-tokens/references/token-tables.md` publishes `LonjaDensity.tapMin` 48 standard /
   56 glove; `lonja-forms-and-controls/references/control-anatomy.md` publishes
   `LonjaTargets.control` 56 / `.gloveControl` 66 and `LonjaTargets.key` 64 / `.gloveKey` 76. Both
   clear `SPEC.md` §4.9's floor of ≥ 48 dp and ≥ 56 dp in glove mode, and both pass
   `check_lonja_controls.sh` check 3, which only bans a numeric literal. **E07 decides which symbol
   exists.** Every task here reads the symbol E07 published and asserts against the SPEC floor;
   nothing hardcodes 48, 56, 64 or 66. If E07 published neither, that is an E07 gap to raise, not a
   local constant to invent.

5. **The measurement-method enum may be shorter than the schema.** `SPEC.md` §7.1
   `measurement_method.code` enumerates nine codes (`TL FL SL CW CL ML DW SHL CUSTOM`) and §4.2 names
   all nine; `catchlaw-measurement-ruler/references/measurement-methods.md` tables six (TL FL SL CW
   SHL ML), omitting CL, DW and CUSTOM. E03 owns the enum. Before T05 and T07 assume a diagram exists
   for every rule row, read what E03 shipped. If it is six, that is a defect to raise against E03 and
   E04 (a `CL` rule row would fail the content build), **not** a seventh case added locally — the
   skill states that adding a method is a reviewed change with a content migration.

6. **Nobody has yet decided who calls `SystemChrome.setPreferredOrientations`.** `SPEC.md` §11 Both
   wants landscape on S3 and S13 and portrait elsewhere; `adaptive-layout` rule 6 bans locking
   orientation. T07 resolves it for this epic only — S3 and S4 widen the allowed set on mount and
   restore the app default on dispose, and the layout itself adapts by constraints so it is correct
   in either orientation. If E01 pinned portrait app-wide with no per-route hook, T07 adds one and
   says so in the commit body.

7. **`LonjaKeypad` may not exist.** E07's scope is the theme foundation. T06 states the fork: consume
   `app/lib/ui/core/ui/lonja_keypad.dart` if E07 published it, otherwise build it there — never in
   `app/lib/ui/ruler/`, because `lonja-forms-and-controls` rule 2 keeps raw Material inputs inside
   `ui/core/`.

8. **A known error source that is inside budget and must not be chased.** Screen-protector parallax
   adds up to ~1 mm at a shallow viewing angle. That is documented in
   `ruler-and-calibration.md` and is the reason the budget is 1.5 mm rather than 0.5 mm. Nobody
   should spend a day on it.

## PR description

### What changed

S3 (ruler) and S4 (calibration) exist. `RulerCalibration` stores one `pxPerMm` scale factor measured
against an ISO/IEC 7810 ID-1 card at 85.60 × 53.98 mm, judged against a 4.50–9.00 px/mm plausibility
band before it is allowed to exist, and persisted to `user_profile.ruler_px_per_mm` /
`ruler_calibrated_at`. `RulerPainter` draws the scale from an immutable `RulerScene` snapshot with a
`shouldRepaint` that is one value compare and a `paint()` that allocates nothing. The ruler subtree
is pinned `TextDirection.ltr` in every locale while its tick labels are formatted through the
locale's `NumberFormat`. Step-and-mark accumulates up to four segments with a running total and a
cancel that restores the previously committed reading. A numeric keypad produces a length on a device
that has never been calibrated. Every length is an integer of millimetres; cm, mm and inch are
display conversions only.

### Why

`SPEC.md` §16 R3: a 45 cm minimum with a 3 mm error is real legal exposure, and a ruler fishers do
not trust is dead weight. Everything here is arranged around two consequences of that sentence — the
scale is measured against a real object rather than derived from `devicePixelRatio`, and the path
that does not need the ruler at all is a first-class path rather than a fallback.

### How it was verified

Unit tests over the plausibility band and the single rounding site; drift tests against
`NativeDatabase.memory()` for the calibration round-trip; `paints`-matcher tests over the painter;
widget tests for step-and-mark, for the keypad on a virgin install, and for the `ar` lane proving the
scale did not mirror; and the T08 accuracy harness run on physical devices, whose numbers are
recorded in the skill's device matrix.

### Product invariants touched

None weakened. Invariant 1 (no network) — the ruler reads a card, not a server; the only new
dependency surface is zero. Invariant 4 (colour is never the only signal) — the implausible-scale
state is a stated sentence plus a glyph, not an ochre frame alone. Invariant 2 (statement of fact,
never an instruction) constrains the calibration and keypad copy as much as it constrains a verdict;
`Return` is a banned word and no control is labelled with it.

### Follow-ups deliberately not in this PR

- Wiring the reading into S2's result banner and the findings list — E10.
- Persisting a reading onto a `catch` row — E13.
- The Settings entry point for recalibration and the units toggle surface — E16.
- The 200% text-scale and greyscale sweeps over S3 and S4 — E19.
- The six-locale golden matrix — E20.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start the next epic.
