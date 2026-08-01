# E13/T05 — Coordinates: opt-in, and a global off

| | |
|---|---|
| **Epic** | E13 — The catch log |
| **Branch** | `epic/13-catch-log` (shared) |
| **Commit** | `feat(log): capture coordinates only when the catch opted in and the global switch is on` |
| **Depends on** | T02 (`record()`, which currently writes NULL coordinates) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.5 (Location privacy), §6 S11 ("coordinates with a clear on/off state") and S14 ("coordinate capture on/off"), §7.2 (`user_profile.capture_coordinates`, `catch.latitude`/`longitude`), §11 (location permission optional and deferred to first use), §13 (GPS single-shot, user-initiated, 20 s timeout) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `service-boundary-and-native` | Rules 1, 4 and 7: the location boundary already exists from E11 — this task consumes that interface and adds no second seam, and the outcome stays a sealed value. |
| `error-handling-typed-results` | Rules 3, 4: a denied permission and a timed-out fix are typed values with stable codes, switched exhaustively with no `default:`. |
| `state-management-riverpod` | Rule 5, the single write path — the privacy rule is enforced in the repository, not in the widget that happens to own the toggle today. |
| `catchlaw-conventions-index` | Invariants 4 and 11 in `references/product-invariants.md`: the on/off state is glyph plus word plus hue, and no identifier ever leaves the device. |
| `lonja-buttons` | Rule 9: a disabled control states its reason in adjacent prose — which is the whole design of the per-catch toggle under a global off. |
| `accessibility-as-code` | Rules 1, 6, 8: the on/off state must be knowable without colour and announced to a screen reader, and the target is ≥ 44 dp. |
| `persistence-drift` | Rule 5: `latitude` and `longitude` are `REAL` in §7.2 and are stored as measured — no formatting, no rounding, no localised value in a column. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.5 row "Location privacy" | "Coordinates opt-in per catch, off by default. A global Settings toggle disables capture entirely" |
| `SPEC.md` | §6 S11 and S14 | "coordinates with a clear on/off state"; "coordinate capture on/off" as an S14 element |
| `SPEC.md` | §7.2 | `user_profile.capture_coordinates INTEGER NOT NULL DEFAULT 0`; `latitude REAL, longitude REAL` — "NULL unless opted in" |
| `SPEC.md` | §11 Android and iOS | Location permissions optional and deferred to first use; `NSLocationAlwaysAndWhenInUseUsageDescription` is **not** declared |
| `SPEC.md` | §13 row "Battery" | "GPS is single-shot, user-initiated, 20 s timeout" |
| `SPEC.md` | §14 dynamic checklist | "Deny location permission: S9 remains fully usable and states why nothing was suggested" — the same posture applies here |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §1 "Allowed", §4, and rule 11's consequences | No identifier leaves the device; three signals per state |
| `$FLUTTER_SKILLS/service-boundary-and-native/references/service-interface.md` | "Why a typed outcome", "Honest guarantees" | The sealed outcome, and what the type system does and does not catch |
| `.claude/skills/lonja-buttons/SKILL.md` | Rule 9 | The disabled control that explains itself |
| `FLUTTER_GUIDE.md` | Part 1.4 | GPS is a Service; E11 already built it and this task adds no second one |
| `epics/DECISIONS.md` | D-3 | Six locales for every new label |

## What this delivers

- `app/lib/domain/models/catch_position.dart` — `CatchPosition(latitude, longitude)`, immutable,
  stored as measured.
- `app/lib/domain/use_cases/capture_position_use_case.dart` — reads the global flag, calls **E11's
  existing** `LocationService`, returns a sealed `PositionOutcome`:
  `PositionCaptured(CatchPosition)`, `PositionDeclinedGlobally`, `PositionPermissionDenied(code)`,
  `PositionTimedOut`.
- `CatchDraft.position` — nullable, defaulting to `null`, plus the repository-side enforcement of the
  global flag in `catch_log_repository_drift.dart`.
- `app/lib/ui/log/widgets/coordinate_toggle.dart` — the per-catch control, off for every catch, with
  the disabled state and its adjacent prose.
- `app/lib/ui/log/widgets/coordinate_state_row.dart` — S11's clear on/off state: glyph, word and hue.
- `app/lib/ui/settings/widgets/coordinate_capture_switch.dart` — the S14 control and its explanatory
  line. **E16 mounts this widget into S14; E16 does not re-implement it.**
- ARB keys ×6 for the toggle label, the global switch label, the "capture is off" prose, the
  permission-denied prose and the two S11 state words.
- Tests: `app/test/domain/use_cases/capture_position_use_case_test.dart`,
  `app/test/data/repositories/catch_log_coordinates_test.dart`,
  `app/test/ui/log/coordinate_toggle_test.dart`,
  `app/test/ui/settings/coordinate_capture_switch_test.dart`.

## Why it is built this way

**The privacy rule lives at the single write path, not in the widget that owns the toggle.**
`CatchLogRepositoryDrift.record` reads `user_profile.capture_coordinates` and, when it is `0`, drops
the draft's position before building the companion — even if the draft carries a fix. A rule enforced
only in a widget is a rule that the next screen forgets: E17's import writes rows, T07's edit writes
rows, and a future "record from the map" screen would write rows too. `state-management-riverpod`
rule 5 says every durable mutation goes through one repository method; this is what that buys.

**Off by default means off for every catch, not off until the first yes.** The toggle resets for each
new catch. **Rejected:** remembering the last choice, which is the friendlier design and the wrong
one — it silently converts one deliberate decision into a standing policy, and the fisher who tagged
one fish to remember a bank never agreed to tag the season.

**The global switch disables capture, not history.** Turning it off stops every future fix; it does
not erase coordinates already stored, because §4.5 says *disables capture* and because the record is
immutable by design. The S14 control states both halves in one line, so nobody has to guess whether
switching it off is retroactive. There is no bulk "strip coordinates" action: it is not in §6, not in
§14, and inventing it here would put a destructive operation on a screen nobody specified. If it is
wanted, it belongs beside T08's photo purge and needs a `SPEC.md` amendment first.

**With the global switch off, the location service is never called at all.** Not called and its result
discarded — never called. `CapturePositionUseCase` short-circuits to `PositionDeclinedGlobally` before
touching E11's `LocationService`, so no fix is taken, no permission prompt appears and no radio is
powered on a device whose owner said no. Test 7 asserts the call count is zero, which is the only way
to prove a negative here.

**A denied permission produces a catch without coordinates, never a blocked catch.** This mirrors
§14's line for the zone picker — *"S9 remains fully usable and states why nothing was suggested"* — and
T04's for the camera. The toggle disables itself and one line of prose says what is missing
(`lonja-buttons` rule 9); the record action stays live.

**Single-shot, user-initiated, 20 seconds.** §13's battery row is explicit, and §11 declares no
background-location permission at all. The use case requests one fix with a 20 s timeout and returns
`PositionTimedOut`; it never subscribes to a stream and never retries. Riverpod's `retry` is already
`null` app-wide (`FLUTTER_GUIDE.md` §5.2 — "offline app: never retry"), and nothing here overrides it.

**Coordinates are stored as measured.** §7.2 types them `REAL`. **Rejected:** truncating to three
decimal places "for privacy". Truncation changes what the opt-in means without telling the person who
gave it, and a fisher who tags a bank he wants to find again needs the precision he thought he was
getting. Privacy here is the choice not to record, and it is binary by design.

**The on/off state on S11 is a state, not the absence of a value.** A row that simply omits the
coordinates when there are none is indistinguishable from a row where the feature is broken. §6 S11
asks for a *clear on/off state*, so the row renders in both cases — glyph, word and hue together,
per invariant 4 and `accessibility-as-code` rule 6 — and reads correctly in a greyscale golden.

## Tests first

Write every row before touching `capture_position_use_case.dart`. Run them. **They must fail.** If one
passes now, the test is wrong.

Read E11's `LocationService` interface before writing the fake: this task consumes it and must not
declare a second one (`service-boundary-and-native` rule 2 — an interface with no second implementation
is dead weight, and E11 already owns this one).

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CatchLogRepository.record writes null coordinates when capture_coordinates is 0` | profile flag `0`, draft carrying a fix | `latitude` and `longitude` NULL | The load-bearing test of the whole task. If it can be defeated by a caller, the setting is decorative |
| 2 | `CatchLogRepository.record writes the coordinates when the global switch is on and the catch opted in` | flag `1`, draft with a position | both columns written | The positive path; without it case 1 passes trivially |
| 3 | `CatchLogRepository.record writes null coordinates when the catch did not opt in` | flag `1`, draft with no position | both NULL | Per-catch opt-in is a second gate, not a formality under a global yes |
| 4 | `CatchLogRepository.record stores latitude and longitude as measured` | 42.2406109, −8.7207315 | the same values, unrounded | Rejecting truncation, as an assertion. A later "privacy" rounding must break this test and argue with it |
| 5 | `CatchDraft defaults to no position` | `CatchDraft(...)` with no position argument | `position` is null | §4.5's "off by default", at the type level |
| 6 | `CapturePositionUseCase returns PositionDeclinedGlobally when the global switch is off` | flag `0` | `PositionDeclinedGlobally` | The typed outcome the UI states, rather than a silent null |
| 7 | `CapturePositionUseCase never calls LocationService when the global switch is off` | flag `0` | fake's call count is 0 | Not called, not called-and-discarded. No permission prompt, no radio, on a device whose owner said no |
| 8 | `CapturePositionUseCase returns PositionPermissionDenied when the permission is refused` | fake denying | `PositionPermissionDenied(code)` | The §14 posture: state why nothing was captured, do not block |
| 9 | `CapturePositionUseCase returns PositionTimedOut after 20 seconds` | fake that never resolves, `fake_async` | `PositionTimedOut` at 20 s, nothing at 19 s | §13's number, asserted on both sides so the timeout is real rather than incidental |
| 10 | `CapturePositionUseCase requests one fix and never subscribes to a stream` | successful fake | single-fix method called once, stream method never | §11 declares no background location; a stream is the first step towards needing it |
| 11 | `CatchLogRepository.record still writes the row when the position lookup fails` | `PositionPermissionDenied` | one row, NULL coordinates, `Ok` | A failed optional capture must never cost the catch — the same rule as T04's denied camera |
| 12 | `SettingsRepository.setCaptureCoordinates(false) leaves stored coordinates on existing catches` | two catches with coordinates, then switch off | both rows unchanged | The switch disables capture, not history. History is immutable and nothing here may make it retroactive |
| 13 | `CoordinateToggle is off when a new catch is started` | fresh draft after a previous catch opted in | toggle off | Not sticky. A remembered yes converts one decision into a policy the fisher never gave |
| 14 | `CoordinateToggle states what is missing when the global switch is off` | flag `0` | control disabled, one line of prose naming the setting | `lonja-buttons` rule 9 — a dead grey switch reads as a broken app |
| 15 | `CoordinateStateRow states coordinates are recorded with a glyph and a word` | a catch with coordinates | glyph + word + hue present | Invariant 4; verified in the greyscale lane |
| 16 | `CoordinateStateRow states coordinates are not recorded` | a catch with NULL coordinates | the off state rendered, not an omitted row | §6 S11's "clear on/off state" — an absent row is indistinguishable from a broken feature |
| 17 | `ar - CoordinateToggle places its control at the end edge` | `ar` golden | control on the end edge, label on the start | `EdgeInsetsDirectional`, not `EdgeInsets.only(left:)`, which D-8's grep gate also bans |
| 18 | `Coordinate capture label exists in <locale>` (loop over `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`) | each ARB file | key present and non-empty | D-3, and §14's static check that every ARB key exists in all six locales |

```dart
// app/test/data/repositories/catch_log_coordinates_test.dart
void main() {
  test('CatchLogRepository.record writes null coordinates when capture_coordinates is 0', () async {
    await settings.setCaptureCoordinates(false);

    // The draft carries a real fix — the repository, not the widget, is what refuses it.
    await repo.record(kDraftAmeixa.copyWith(
      position: const CatchPosition(latitude: 42.2406109, longitude: -8.7207315),
    ));

    final row = await db.select(db.catches).getSingle();
    expect(row.latitude, isNull);
    expect(row.longitude, isNull);
  });

  test('SettingsRepository.setCaptureCoordinates(false) leaves stored coordinates on existing catches',
      () async {
    await settings.setCaptureCoordinates(true);
    await repo.record(kDraftAmeixa.copyWith(position: kPositionRiaDeArousa));
    final before = await db.select(db.catches).getSingle();

    await settings.setCaptureCoordinates(false);

    expect(await db.select(db.catches).getSingle(), equals(before)); // history is immutable
  });
}
```

```dart
// app/test/domain/use_cases/capture_position_use_case_test.dart
test('CapturePositionUseCase never calls LocationService when the global switch is off', () async {
  final location = FakeLocationService.succeeding(kPositionRiaDeArousa);
  final useCase = CapturePositionUseCase(location: location, captureEnabled: false);

  expect(await useCase.capture(), isA<PositionDeclinedGlobally>());
  expect(location.calls, 0); // not called — not called and discarded
});

test('CapturePositionUseCase returns PositionTimedOut after 20 seconds', () {
  fakeAsync((async) {
    final future = CapturePositionUseCase(
      location: FakeLocationService.neverResolving(),
      captureEnabled: true,
    ).capture();

    async.elapse(const Duration(seconds: 19));
    expect(future, doesNotComplete);          // still waiting at 19 s
    async.elapse(const Duration(seconds: 1));
    expect(async.pendingTimers, isEmpty);     // and gave up at 20 s — SPEC §13
  });
});
```

**Run:** `cd app && flutter test test/domain/use_cases/capture_position_use_case_test.dart test/data test/ui`
→ 18 failures.

## Implementation outline

1. Read E11's `LocationService` interface first. Consume it; declare nothing parallel. If its
   single-shot method does not already carry a timeout parameter, pass the 20 s at the call site rather
   than editing E11's seam.
2. `catch_position.dart` — a two-field immutable value object with a `const` constructor. No
   formatting, no `toString` that rounds.
3. `capture_position_use_case.dart` — the sealed `PositionOutcome` and the short-circuit. The global
   flag is read *before* the service is touched.
4. `catch_log_repository_drift.dart` — read `capture_coordinates` alongside the active zone, outside
   the transaction, and drop the draft's position when it is `0`. One line, one test, one comment
   pointing at §4.5.
5. `coordinate_toggle.dart` — a `LonjaSwitch` (owned by `lonja-forms-and-controls`) with the disabled
   state and its prose. It reads the global flag with `.select` so it does not rebuild on every tally
   change.
6. `coordinate_state_row.dart` — both states rendered, glyph and word and hue, `Semantics` value set
   so the state is announced rather than seen.
7. `coordinate_capture_switch.dart` under `app/lib/ui/settings/widgets/` — the S14 control plus its
   one line stating that switching off stops future capture and leaves stored coordinates alone. E16
   mounts it.
8. ARB keys in all six locales of D-3. None of them instructs; they state.
9. Re-run the whole suite. T02's test 14 asserted NULL coordinates for a draft carrying a fix — that
   test now describes the *global-off* case and must still pass unchanged.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] With `capture_coordinates = 0`, no code path in `app/lib` can write a non-NULL `latitude` or
      `longitude` — proven at the repository, with a draft that carries a fix.
- [ ] `grep -rn "LocationService" app/lib | grep -v "app/lib/data/services"` shows only consumers, and
      no second location interface exists.
- [ ] The per-catch toggle is `false` for every new draft; no persisted "last choice" exists anywhere.
- [ ] Switching the global flag off changes no existing row.
- [ ] The 20 s timeout is asserted on both sides (nothing at 19 s, given up at 20 s).
- [ ] Both S11 coordinate states carry a glyph, a word and a hue, and both survive a greyscale golden.
- [ ] No new location permission appears in either platform manifest; in particular
      `NSLocationAlwaysAndWhenInUseUsageDescription` is still absent (§11).
- [ ] Every new label exists in all six locales of D-3 and none of them instructs.

## Gates

```bash
dart format --set-exit-if-changed .
cd app && flutter analyze && flutter test && cd ..
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                 app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
$FLUTTER_SKILLS/service-boundary-and-native/scripts/check-service-boundaries.sh app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh   app/lib
```

`tools/gates/no_directional_geometry.sh` is D-8's grep gate, shipped by E06/T05; it is what bans
`EdgeInsets.only(left:` on the new toggle rows.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(log): capture coordinates only when the catch opted in and the global switch is on

The privacy rule is enforced in the repository, not in the widget that owns
the toggle. Everything that writes a catch — the record path, T07's edit, E17's
import, any screen written next year — goes through one method, and that method
drops a position when user_profile.capture_coordinates is 0 even if the draft
carries a fix.

With the global switch off, LocationService is never called. Not called and
its result discarded: never called, so no permission prompt appears and no
radio is powered on a device whose owner said no.

Off by default means off for every catch. Remembering the last yes would be
friendlier and wrong — it turns one deliberate decision into a standing policy
the fisher never gave.

Switching the global flag off stops future capture and leaves stored
coordinates alone. SPEC §4.5 disables capture, and the record is immutable; the
S14 line says both halves so nobody has to guess whether it is retroactive.

Task: E13/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
