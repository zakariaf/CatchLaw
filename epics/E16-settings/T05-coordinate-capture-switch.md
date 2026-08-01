# E16/T05 — The coordinate-capture master switch

| | |
|---|---|
| **Epic** | E16 — Settings |
| **Branch** | `epic/16-settings` (shared) |
| **Commit** | `feat(settings): add the coordinate-capture master switch` |
| **Depends on** | T02 (the screen shell and `SettingsRow`), E13 (the per-catch opt-in and the catch write path) |
| **Size** | S |
| **Spec** | `SPEC.md` §6 S14 (coordinate capture on/off), §4.5 Location privacy ("Coordinates opt-in per catch, off by default. A global Settings toggle disables capture entirely"), §7.2 (`capture_coordinates INTEGER NOT NULL DEFAULT 0`; `latitude REAL, longitude REAL` — "NULL unless opted in"), §11 (`NSLocationAlwaysAndWhenInUseUsageDescription` is not declared; no background location) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-forms-and-controls` | Rule 11 again: the master switch is a square whose state is a word, at `LonjaTargets.control` |
| `lonja-lists-and-tables` | Rule 8 — a row states and never instructs; the sub-line here is a statement of fact about what is and is not stored |
| `catchlaw-conventions-index` | Rule 11 — no identifier ever leaves the device; a coordinate is the most identifying thing this app can hold, and the master switch is the one control that makes it unrepresentable |
| `state-management-riverpod` | Reading the master flag at the write path, not only in the UI |
| `service-boundary-and-native` | `LocationService` is a service; the gate belongs above it, so the platform channel is never reached when capture is off |
| `accessibility-as-code` | The toggled state on a privacy control, and the sub-line being part of the accessible name rather than decoration |
| `persistence-drift` | Asserting `latitude`/`longitude` are `NULL` at the row, which is where the guarantee actually lives |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.5, Location privacy row | "Coordinates opt-in per catch, off by default. **A global Settings toggle disables capture entirely.**" Two levels, and the global one is the master |
| `SPEC.md` | §7.2, `catch` DDL | `latitude REAL, longitude REAL` with the comment "NULL unless opted in"; and `user_profile.capture_coordinates INTEGER NOT NULL DEFAULT 0` |
| `SPEC.md` | §6 S11 | "coordinates with a clear on/off state" — the per-catch control this switch sits above |
| `SPEC.md` | §6 S9, Note and Error state | The zone picker's own single-shot fix, which stores nothing and is a different thing from catch capture |
| `SPEC.md` | §11 Android / iOS | Location permission is optional and deferred to first use; no background-location permission is declared on either platform |
| `SPEC.md` | §13, Battery row | "GPS is single-shot, user-initiated, 20 s timeout" — there is no continuous capture for this switch to stop |
| `.claude/skills/lonja-forms-and-controls/SKILL.md` | Rule 11; rule 3 | The square toggle with a state word; targets from `LonjaTargets` |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | Rule 8 | The end slot states; no imperative anywhere in a row |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The settings row" | The sub-line slot this task's second sentence occupies |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | Rule 11 | "No account, no login, no sync, and no identifier ever leaves the device" |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §1, allowed list | `Share.shareXFiles` for a user-initiated export is the only outbound path; a coordinate is data the user chose to hold, not data we collect |
| `epics/CONVENTIONS.md` | §5, §9 | Test naming; the invariants |

## What this delivers

- `app/lib/ui/settings/widgets/settings_coordinates_row.dart` — `SettingsCoordinatesRow`, a
  `SettingsRow` with a `LonjaSwitch` and a two-line sub-line.
- The gate itself, at the catch write path: the use case that records a catch reads
  `captureCoordinates` and, when it is false, never calls `LocationService` and writes `null` into
  both columns. This is a change to E13's recording path, in this commit.
- The per-catch opt-in control (E13, S11) is not rendered at all when the master is off.
- ARB keys in all six locales: `settingsSectionPrivacy`, `settingsCaptureCoordinatesLabel`,
  `settingsCaptureCoordinatesDetail`, `settingsCaptureCoordinatesKeptDetail`.
- `app/test/ui/settings/settings_coordinates_row_test.dart`,
  `app/test/domain/use_cases/catch_record_coordinates_test.dart`.

## Why it is built this way

**The switch disables capture, it does not hide a control.** `SPEC.md` §4.5 says the global toggle
"disables capture entirely". A master that only hides the per-catch checkbox is a UI change dressed as
a privacy guarantee: any other code path that records a catch — a quick-add from S8, an import, a
future screen — would still write a position. So the gate lives at the write path, in the use case that
records a catch, above `LocationService`. Row 3 asserts it at the DAO, where the guarantee actually
lives, and row 4 asserts `LocationService` is never called at all, so the OS permission prompt never
appears either. **Rejected: gating in the widget**, which is the version that passes review and fails
at the second call site.

**Two levels, and the master is above.** Per-catch opt-in is E13's and stays E13's; this switch is the
floor beneath it. With the master off there is no per-catch control to see, because a control that
cannot do anything is worse than an absent one. With the master on, the per-catch default is still off
(`SPEC.md` §4.5: "off by default"), so turning the master on grants permission to ask, not permission
to store.

**Turning it off does not erase what is already stored.** `SPEC.md` says nothing about retroactive
deletion, and inventing it would be silent data loss on a log the user cannot recover from anywhere —
there is no cloud copy (`catchlaw-conventions-index` rule 11 cuts both ways). So the row states the
fact in its sub-line: coordinates already saved on past catches are kept, and S11's per-catch editor
is where a single one is cleared. **Rejected: a purge-on-disable**, and **rejected: silence**, which
would leave the user guessing what just happened to three years of positions.

**S9's "Use my location" is a different act and is unaffected.** `SPEC.md` §4.5's toggle is in the
catch-log table and governs *storing coordinates on a catch*. S9's single-shot fix suggests a zone and
stores no position at all (`SPEC.md` §6 S9, §4.4: "Suggests, never auto-switches"). Conflating the two
would silently remove the zone suggestion for anyone who turned off coordinate storage — two unrelated
capabilities behind one switch. Row 6 pins the distinction.

**The wording states, it does not instruct.** `lonja-lists-and-tables` rule 8 and
`CONVENTIONS.md` §9 invariant 2. The sub-line reads as a fact about the app's behaviour — what is
stored, what is not, what is kept — and never as advice about whether the user should turn it on.

**There is nothing to stop in the background.** `SPEC.md` §13 says GPS is "single-shot, user-initiated,
20 s timeout" and §11 declares no background-location permission on either platform. So this switch has
no service to shut down and no subscription to cancel; it changes whether one function is ever called.
Saying so here stops someone adding a "location is off" listener that implies otherwise.

## Tests first

Write every row before touching either the widget or E13's write path. Run them. **They must fail.**
Row 3 in particular must fail against the current E13 code — if it passes, the gate already exists
somewhere and this task's job is to find and consolidate it, not to add a second one.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SettingsCoordinatesRow renders off by default` | fresh settings | the `off` word, switch unfilled | `SPEC.md` §7.2 defaults `capture_coordinates` to `0`; an inverted boolean map would default the app to capturing positions |
| 2 | `SettingsCoordinatesRow writes true when the switch is tapped` | tap | `setCaptureCoordinates(true)` once | The write path |
| 3 | `CatchRecordUseCase writes null coordinates when captureCoordinates is false` | a fix available, master off | `latitude` and `longitude` are `NULL` in the row | The guarantee, asserted where it lives; a widget-level gate passes review and fails at the second call site |
| 4 | `CatchRecordUseCase does not call LocationService when captureCoordinates is false` | master off | the fake service records zero calls | No call means no OS permission prompt; a gate that fetches then discards still prompts and still reads a position |
| 5 | `CatchRecordUseCase writes null coordinates when the per-catch opt-in is false and the master is true` | master on, per-catch off | both columns `NULL` | The master grants permission to ask, not permission to store; §4.5 keeps the per-catch default off |
| 6 | `ZonePicker requests a single-shot fix when captureCoordinates is false` | master off, tap "Use my location" | the fix is requested | The two capabilities are separate; conflating them silently removes S9's suggestion for every privacy-minded user |
| 7 | `SettingsCoordinatesRow states that saved coordinates are kept` | master on → off | the "kept" sub-line renders | Silence here leaves the user guessing whether three years of positions were just deleted |
| 8 | `SettingsCoordinatesRow performs no delete when the switch is turned off` | on → off, with a catch carrying coordinates | the stored `latitude` is unchanged | The rejected purge-on-disable, asserted so nobody adds it later as a "privacy improvement" |
| 9 | `CatchDetailScreen renders no coordinate control when captureCoordinates is false` | master off | the per-catch control is absent, not disabled | A control that cannot act is worse than an absent one; and E13's screen must read the master, not a copy of it |
| 10 | `glove - SettingsCoordinatesRow measures 66 dp` | `gloveMode: true` | switch target ≥ 66 | `LonjaTargets.gloveControl`, on a control added after T04 |
| 11 | `SettingsCoordinatesRow contains no imperative` | pump in all six locales | no banned verb in the rendered strings | `CONVENTIONS.md` §9 invariant 2 and `lonja-lists-and-tables` rule 8 — a privacy row is the easiest place to slip into advice |

```dart
// app/test/domain/use_cases/catch_record_coordinates_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_location_service.dart';
import '../../../testing/fakes/fake_settings_repository.dart';

void main() {
  test('CatchRecordUseCase does not call LocationService when captureCoordinates is false',
      () async {
    final location = FakeLocationService(fix: const (lat: 25.79, lon: 55.94));
    final settings = FakeSettingsRepository();          // capture_coordinates defaults to 0
    final db = UserDatabase(NativeDatabase.memory());
    final useCase = CatchRecordUseCase(
      settings: settings,
      location: location,
      catches: CatchRepositoryDrift(db),
    );

    await useCase.record(kCatchDraftHamour);

    // No call at all — not a call whose result is discarded, which still prompts.
    expect(location.callCount, 0);

    final row = await db.customSelect('SELECT latitude, longitude FROM "catch"').getSingle();
    expect(row.read<double?>('latitude'), isNull);
    expect(row.read<double?>('longitude'), isNull);
    await db.close();
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/settings/settings_coordinates_row_test.dart
test/domain/use_cases/catch_record_coordinates_test.dart` → 11 failures. If any passes now, the test is
wrong.

## Implementation outline

Only after the tests are red.

1. `settings_coordinates_row.dart` — a `SettingsRow` with a `LonjaSwitch`, the state word, and the
   two-sentence sub-line. Both sentences are ARB keys.
2. The gate. In E13's catch-recording use case, read `captureCoordinates` from
   `SettingsRepository` once, before any location work. When it is false, skip `LocationService`
   entirely and pass `null` for both columns. This is the only place the master is consulted for a
   write.
3. E13's S11 catch-detail screen: render the per-catch coordinate control only when the master is on.
   It reads the same provider; it holds no copy of the flag.
4. Six ARB files, four new keys, one commit (D-3).
5. Re-run the whole suite. Every E13 catch test must still be green; the ones that recorded a
   coordinate need `captureCoordinates: true` in their fixture now, and that is a fixture change, not
   a behaviour change.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 11 rows pass, and each failed first.
- [ ] `grep -rn "LocationService" app/lib` shows the catch path calling it only inside the
      `captureCoordinates` branch; S9's zone suggestion is the only other call site.
- [ ] `grep -rn "captureCoordinates" app/lib` shows one read for the write gate, one read for the S11
      control, one read for this row — and no field or local caching it.
- [ ] No code path deletes a stored `latitude` or `longitude` in this commit.
- [ ] The four new ARB keys exist in all six locales, and none contains an imperative (row 11).
- [ ] Golden lanes: `en` paper on and off, `ar` paper on, `ar` paper glove on.
- [ ] `SettingsScreen` still builds zero `LonjaButtonVariant.primary`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh        app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
tools/gates/no_directional_geometry.sh                                    app/lib
```

`check_verdict_contract.sh` runs here because this row's copy is the easiest place in the app to slip
from a statement into advice, and it scans the ARB files as well as the Dart source (D-7).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(settings): add the coordinate-capture master switch

SPEC 4.5 says the global toggle disables capture entirely, so the gate is
at the catch write path and not in the widget: a widget-level gate hides
one checkbox and lets every other recording path — quick-add, import, the
next screen someone writes — keep storing a position. With the master off
LocationService is never called at all, so the OS permission prompt never
appears either.

Turning it off deletes nothing. There is no cloud copy of the catch log,
so a retroactive purge nobody asked for is unrecoverable data loss; the row
states that saved coordinates are kept and S11 is where one is cleared.

S9's "Use my location" is unaffected and a test pins that: it suggests a
zone and stores no position, and putting two unrelated capabilities behind
one switch would silently remove the suggestion for everyone who values
the privacy this switch exists for.

Task: E16/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
