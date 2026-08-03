### What changed

The measurement subsystem: a screen measured against a card, one transform, and a ruler that does
not mirror.

- **The calibration** — ID-1 constants with their sources, a sealed `CalibrationOutcome`, and a
  repository that writes exactly two columns of `user_profile`.
- **`RulerCalibration`** — the **one shared transform**. `millimetresFor` and
  `pixelsForMillimetres` are exact inverses, and everything in the app converts through them.
- **`RulerScene` + `RulerPainter`** — a value-type scene so `shouldRepaint` is one compare, and a
  painter whose constructor allocates and whose `paint` does not.
- **`LtrInstrument`** — `SPEC.md` §9.3's one documented exception, in one file.
- **`MeasurementDraft`** — segments for a fish longer than the phone, and a cancel that **restores**.
- **Manual entry** — an integer accumulator that works with no calibration at all.
- **`formatMeasurement`** — no overload without a method.
- **The accuracy harness** — the software claim asserted exactly, the physical claim reported.

### Why

Flutter cannot tell you a panel's physical DPI. `devicePixelRatio` is a logical-to-physical ratio and
no arithmetic on it yields millimetres, so a constant scale is a saved 40% error. The fisher lays a
card he already carries on the glass and the app divides — and a bank card, a driving licence and an
Emirates ID are all ID-1 to a tolerance far tighter than a fish measurement needs.

### The three decisions that carry the epic

1. **The ruler does not mirror.** It is not a layout, it is an *instrument*: a physical scale runs
   from a physical edge, and mirroring it puts zero at the tail of a real fish while the fisher's
   hand is at the snout. The exception lives in one wrapper, wraps the canvas and nothing else — the
   chrome around it still mirrors, and a row asserts that — and carries the gate's documented hatch.
   **This is the first legitimate hatch in the repository**, and E06/T05's assertion was
   *strengthened* rather than relaxed: it said "zero hatches" and named the file that would earn the
   first; it now says "exactly this file".
2. **Cancel restores, it does not clear.** The behaviour most likely to be written the obvious wrong
   way. Wet hands hit cancel by accident, and a cancel that wiped an accepted 380 mm costs a length
   that cannot be retaken once the fish is in the bin. Accepting an empty draft leaves the
   commitment alone for the same reason, and a cleared commitment stays `null` rather than becoming
   zero — those are two different states.
3. **Manual entry works on a virgin install.** `SPEC.md` §4.2's acceptance condition. The headline
   row measures 45 cm against a real, empty `user.db`, asserts the store is still untouched
   afterwards, and runs the same entry in a container where the calibration provider is a throwing
   placeholder — so "manual entry never consults a scale" is structural rather than incidental.

### One thing this PR raises rather than decides

**`integration_test` pulls `sync_http`, `webdriver` and `flutter_driver` transitively — two HTTP
clients.** The task file asks for an on-device harness in `app/integration_test/`. I added the
dependency, looked at what it brought, and reverted it. Dev-only HTTP has a precedent here
(`build_runner`'s watch server, and the `deps_dev_only_http` fixture), so it may well be fine — but
`SPEC.md` §14's edge-level guarantee names `http` and not `sync_http`, and widening it belongs in
`epics/DECISIONS.md` as a `D-n`, not in a pubspec inside a task. The software half of the accuracy
claim needs no device, so it is a widget test and nothing is lost by waiting. **E21 (release) should
settle this**, because it is the epic that owns the shipped bundle.

### Gate findings kept rather than worked around

- `check_measurement` check 5 flagged three px-per-mm constants. They carry the gate's documented
  hatch with a per-line reason — two are validity bounds, one is a drag handle's start position —
  and the hatch is only honest because a **new source scan enforces the claim beside it**: no file
  that converts pixels to millimetres may name the nominal, and exactly one file in `lib/` divides
  by a scale at all.
- `check_measurement` check 2 rejected a bare `50 mm` in an ARB value. It cannot tell a fish length
  from a calibration bar — but its fix is right anyway: the bar's length is a placeholder now, so it
  is authored once in Dart rather than typed into six translations.
- `check_rule_engine` rejected `listEquals` in `lib/domain/`. A domain type that needed the framework
  to compare two ints would not be a domain type.
- The millimetres-only proof found a **real duplication I had introduced**: `25.4` written twice. It
  now lives once, in the domain layer beside the length it converts.

### Product invariants touched

None weakened. Millimetres are the only stored unit and that is now structural — three rows: no
column holds a length as a real or a text, no domain field holds one as a double, and the inch factor
is named in exactly one place.
