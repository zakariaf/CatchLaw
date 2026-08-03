# E11/T06 — GPS suggests, and a denied permission costs nothing

| | |
|---|---|
| **Epic** | E11 — Zones and point-in-polygon |
| **Release** | **v2 — deferred.** Not built for v1; see `epics/RELEASES.md` |
| **Branch** | `epic/11-zones` (shared) |
| **Commit** | `feat(zones): take one GPS fix behind a typed service and offer a zone rather than switching` |
| **Depends on** | T03 (`LocateZone`), T04 (the picker and its view model) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.4 ("GPS zone suggestion": suggests, never auto-switches; fully usable with location denied), §6 S9 (the error state — the manual list stays fully usable, with one line saying why), §11 (Android and iOS permissions, no background modes, no `NSLocationAlwaysAndWhenInUse`), §13 (GPS is single-shot, user-initiated, 20 s timeout), §14 (the static manifest checks and the "deny location" dynamic check) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `service-boundary-and-native` | Owns this whole seam: rules 1, 3, 4, 5, 6, 7 and 8 — an injected interface naming value types only, a sealed outcome instead of `bool`/`throw`, a provider that throws until overridden, one live impl at the composition root, a hand-written fake whose failure paths are reachable |
| `error-handling-typed-results` | Rules 4, 5 and 6: the outcome switch is exhaustive with no `default:`, the plugin exception is converted at the boundary after logging `(e, st)`, and nothing is swallowed |
| `state-management-riverpod` | Rules 2, 5 and 10, and `references/reads-and-side-effects.md`: the fix is an intent method returning `void`, the suggestion is state, and the write only happens on a tap |
| `lonja-navigation-chrome` | Rule 9 (a zone is chosen, never inferred — never a locating spinner or a signal bar) and rule 11 (no connectivity, sync or refresh affordance anywhere in chrome) |
| `lonja-lists-and-tables` | Rules 6, 8 and 9: the suggestion is a row that states rather than instructs, its status is glyph + word + colour, and the no-match case is an authored state |
| `catchlaw-conventions-index` | Invariants 1 and 2: no network symbol reaches this feature, and the reason line states a fact rather than telling the fisher what to do about it |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.4, "GPS zone suggestion" | "Optional single-shot fix, matched by on-device point-in-polygon against bundled rings. Suggests, never auto-switches; fully usable with location denied" |
| `SPEC.md` | §6 S9, "Error state" | "location denied or no fix → the manual list stays fully usable, with one line saying why" |
| `SPEC.md` | §11, Android | `ACCESS_COARSE_LOCATION` / `ACCESS_FINE_LOCATION`, both optional and **deferred to first use**; no services, no `WAKE_LOCK`, no boot receiver; the `tools:node="remove"` form and why `xmlns:tools` is required |
| `SPEC.md` | §11, iOS | `NSLocationWhenInUseUsageDescription` localised into all six languages; **`NSLocationAlwaysAndWhenInUseUsageDescription` is not declared**; no background modes |
| `SPEC.md` | §13, "Battery" | "No background execution, no polling, no radios. GPS is single-shot, user-initiated, 20 s timeout" |
| `SPEC.md` | §14, static | The built manifest carries no background-location permission; `Info.plist` declares no `NSLocationAlwaysAndWhenInUse` |
| `SPEC.md` | §14, dynamic | "Deny location permission: S9 remains fully usable and states why nothing was suggested" — this task makes that check passable |
| `SPEC.md` | §10 | `geolocator ^13.0` — "Single-shot GPS fix only. No geocoding, no map, no network", and the banned list that keeps a map out |
| `.claude/skills/service-boundary-and-native/references/service-interface.md` | "Why a typed outcome", "Check every return code by hand", "The arrow-callback Future-drop hole", "Fakes over mocks" | The outcome-type table, the wire-level check, the `void` handler, and the `enum`-driven fake with the absence-of-a-failure-class test |
| `.claude/skills/service-boundary-and-native/SKILL.md` | rules 1–8 | The seam in full, and the ban on user-facing copy inside a service |
| `.claude/skills/error-handling-typed-results/references/result-failure-spine.md` | "Failure taxonomy per boundary", "Convert-at-the-boundary" | Stable `code` plus typed params, and log before returning |
| `.claude/skills/state-management-riverpod/references/reads-and-side-effects.md` | "Action-path methods return `void`", "Guarding after await" | The Future-drop hole no lint catches, and `ref.mounted` after the 20 s await |
| `.claude/skills/lonja-navigation-chrome/references/chips-and-currency.md` | "Copy rules" | `Detecting location…` and `Zone: nearest` are forbidden outright; a zone is chosen, never inferred |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Error", "Banned copy" | A local failure states the fact and names what still works; "Check your connection" and any cloud glyph are banned |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 1, "Allowed" | `url_launcher` is permitted only for `mailto:` and `tel:` on the about screen — so there is no route to the system settings screen from here |
| `FLUTTER_GUIDE.md` | §1.4 | GPS is a Service: "Camera, GPS, PDF writing and `rootBundle` are each a Service too", and `location_service.dart` is named in §2.5's tree |
| `FLUTTER_GUIDE.md` | §1.6 | Why the outcome is a sealed union rather than a nullable position |
| `epics/DECISIONS.md` | D-3 | The reason lines land in all six ARB files |

## What this delivers

- `app/lib/data/services/location_service.dart` — `abstract interface class LocationService` with a
  single `@useResult Future<LocationOutcome> currentFix()`, and the sealed outcome family:
  `LocationFix(point: LatLon, accuracyMetres: double, at: DateTime)`;
  `sealed class LocationUnavailable` with `LocationPermissionDenied` (`location.permission_denied`),
  `LocationPermissionDeniedForever` (`location.permission_denied_forever`),
  `LocationServicesDisabled` (`location.services_disabled`),
  `LocationFixTimedOut` (`location.timed_out`, param `int seconds`) and
  `LocationUnsupported` (`location.unsupported`, param `String platformCode`).
- `app/lib/data/services/location_service_geolocator.dart` — the only file in the repository that
  imports `package:geolocator`.
- `app/lib/data/service_providers.dart` gains `locationServiceProvider`, throwing
  `UnimplementedError` until `app/lib/main.dart` overrides it.
- `app/testing/fakes/fake_location_service.dart` — `implements LocationService`, driven by
  `enum LocationEnv { healthy, denied, deniedForever, servicesOff, timesOut, unsupported }`.
- `app/lib/ui/zones/view_models/zone_suggestion_view_model.dart` — `ZoneSuggestionNotifier extends
  Notifier<ZoneSuggestionState>` with `void requestFix()` and `void acceptSuggestion(String zoneCode)`.
- `app/lib/ui/zones/widgets/use_my_location_row.dart`, `zone_suggestion_row.dart` and
  `location_notice.dart`.
- `app/lib/l10n/app_*.arb` × 6 — `zoneUseMyLocation`, `zoneSuggestionHeadline`,
  `zoneLocationDenied`, `zoneLocationDeniedForever`, `zoneLocationServicesOff`,
  `zoneLocationTimedOut`, `zoneLocationUnsupported`, `zoneLocationNoZoneMatched`.
- `app/pubspec.yaml` — `geolocator: ^13.0` (§10), plus the matching line in the checked-in
  direct-dependency allowlist E01 ships, in this same commit.
- `app/android/app/src/main/AndroidManifest.xml` — `ACCESS_COARSE_LOCATION` and
  `ACCESS_FINE_LOCATION`; and, if the merged manifest contributes one,
  `<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" tools:node="remove" />`.
- `app/ios/Runner/Info.plist` plus the six `InfoPlist.strings` files —
  `NSLocationWhenInUseUsageDescription` only.
- `app/test/data/services/location_service_geolocator_test.dart`,
  `app/test/ui/zones/zone_suggestion_test.dart`,
  `app/test/ui/zones/location_notice_test.dart`,
  `app/test/platform/location_manifest_test.dart`.

## Why it is built this way

**A typed outcome, because every other return shape loses the reason.**
`service-interface.md`'s table is the argument: `bool` cannot distinguish "the fisher said no" from
"the receiver has no sky"; a `throw` is forgotten because Dart declares nothing; `Result<Exception>` has
nothing to switch on. Five ways this fails and each needs different words on screen, so the outcome is
sealed and the picker's `switch` over it has no `default:` — a sixth failure mode becomes a compile
error at the one place that renders it.

**The service holds no words.** `service-boundary-and-native`'s anti-patterns name user-facing copy
inside a service explicitly, and D-7 makes the same cut one layer down. `LocationPermissionDenied`
carries the code `location.permission_denied` and nothing else; the sentence is an ARB key in six
locales, chosen at the presentation edge. A message baked into the outcome could not be translated,
could not mirror for RTL and could not have its numerals re-rendered — and §9.3 re-renders numerals.

**Single-shot, user-initiated, 20 s.** §13's battery row fixes all three words. `currentFix()` calls
`getCurrentPosition` once, wrapped in a 20 s `.timeout`, and returns
`LocationFixTimedOut(seconds: 20)` rather than hanging. There is no stream, no polling and no repeat: a
`getPositionStream` subscription is background execution by another name, and §11 has no background
modes, no `WAKE_LOCK` and no boot receiver.

**`getLastKnownPosition` is never called, and that is a decision worth its line.** It is free and
instant and it is the wrong answer: a cached fix can be hours old and a hundred kilometres away, and it
would suggest a zone with exactly the same confidence as a live one. A suggestion that is silently stale
is worse than a spinner, because the fisher has no way to tell. If no live fix arrives in 20 s, the
answer is "no fix", stated.

**The permission is requested inside `currentFix()` and nowhere else.** §11 says permissions are
"optional and deferred to first use". Asking at launch trains the reflex that denies it, and it would
also put a platform-channel round trip on the cold-start path §13 budgets at 1.2 s.

**`LocationAccuracy.medium`, and it is a choice rather than a citation.** A bundled fishing zone is
kilometres across; a few hundred metres of uncertainty cannot move a fix across a ría. Medium accuracy
returns faster and costs less radio than `best`, which is what §13's "negligible" battery row wants.
Nothing in `SPEC.md` fixes the constant, so this is recorded as a design decision here and E21 confirms
on hardware that a medium fix lands inside the right ring on a real boat.

**The fix suggests and the fisher accepts.** §4.4 is unambiguous — "Suggests, never auto-switches" — and
`lonja-navigation-chrome` rule 9 gives the reason from the other side: a zone is a chosen jurisdiction,
not a sensor reading, and animating it implies a lookup that never happens. So `requestFix()` writes
nothing durable. It puts a `ZoneSuggestion` in view-model state, the screen renders one row per candidate
zone with the zone name and the level it sits at, and `acceptSuggestion(zoneCode)` — reached only by a
tap — is what calls `SettingsRepository`. Test 8 drives a successful fix to completion and asserts
`user_profile` is untouched.

**An ambiguous fix shows both rows.** T02 returns `ZoneAmbiguous` when two zones at equal specificity
both contain the point, and this screen is where that decision pays: two rows, both tappable, neither
pre-selected. `catchlaw-rule-engine` rule 6's argument — printing both gives him two citations he can
read aloud — applies to a zone as much as to a rule.

**Denied costs nothing, and "nothing" is a testable claim.** §6 S9's error state and §14's dynamic
checklist both say the manual list stays *fully usable*. So the denied path changes exactly one thing:
one line appears under the "Use my location" row. Every level still renders, every row is still tappable,
the water toggle still works, and no dialog, no dim and no disabled control appears anywhere. Tests 10 to
13 assert the levels are present and interactive under all four unavailable outcomes, not merely that a
message appeared.

**There is no route to the system settings screen.** It is the obvious next affordance and it cannot be
built: `url_launcher` and `AndroidIntent` are grep-banned by §14 and
`product-invariants.md` permits `url_launcher` only for `mailto:` and `tel:` on the about screen. It is
also the wrong shape — "Location permission is not granted, so no zone was suggested" is a statement of
fact, and "Open Settings" is an instruction (invariant 2). The line states what is true and the picker
below it already works.

**A fix that matches no ring is a fourth kind of nothing, and it gets its own line.**
`LocationFix` + `NoZoneMatched` is not a failure: the fisher is somewhere no bundled instrument covers,
or in a jurisdiction whose authority publishes no coordinate boundaries at all (T05). The line names
that fact — "No bundled zone covers this position" — and does not apologise or suggest the nearest,
because the nearest zone to a position outside every zone is not a rule that applies there.

**Rejected: an accuracy readout or a signal indicator.**
`chips-and-currency.md` forbids a chip that shows GPS accuracy outright, and "Detecting location…" is on
its banned-copy list. An accuracy number invites the fisher to evaluate a measurement whose relationship
to "am I in the right ría" he cannot compute, and a signal bar is chrome advertising a radio §13 wants
silent.

**Rejected: falling back to a coarse fix when fine is denied.** Android's two permissions are separate
and `geolocator` will return a coarse fix under `ACCESS_COARSE_LOCATION` alone — which is fine, and
happens without any code from us. What is rejected is *re-prompting* for fine after a coarse grant: it
is a second dialog for an improvement the zone question does not need.

**Rejected: caching the last suggestion across app launches.** It would be a stale sensor reading
promoted to a stored fact, with no timestamp on screen. The fix is cheap and user-initiated; take a new
one.

## Tests first

Write every row before touching `location_service.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LocationServiceGeolocator returns a LocationFix carrying the position and its accuracy` | mocked channel returning a position | `LocationFix` with both fields | The happy path, and the only outcome that carries data |
| 2 | `LocationServiceGeolocator returns LocationFixTimedOut after twenty seconds` | `fakeAsync`, channel never answers | `LocationFixTimedOut(seconds: 20)` at t = 20 s, not before | §13 fixes the number; a hanging fix on a boat is indistinguishable from a crashed app |
| 3 | `LocationServiceGeolocator returns LocationPermissionDenied when the permission is refused` | permission `denied` | that subtype, with its code | The §14 dynamic check, at the layer where it is cheap to prove |
| 4 | `LocationServiceGeolocator returns LocationPermissionDeniedForever when the permission is permanently refused` | permission `deniedForever` | that subtype | Different words on screen: this one will not re-prompt, and the fisher deserves to know |
| 5 | `LocationServiceGeolocator returns LocationServicesDisabled when location services are off` | services off | that subtype | Denied and switched-off are different facts and the same message for both is a lie about one of them |
| 6 | `LocationServiceGeolocator converts a PlatformException into LocationUnsupported` | channel throws | `LocationUnsupported(platformCode: …)`, and the exception is logged first | Convert at the boundary; a `PlatformException` reaching a view model is the listed anti-pattern |
| 7 | `LocationServiceGeolocator requests the permission only inside currentFix` | construct the service, do not call it | no platform call | §11: deferred to first use, and off the 1.2 s cold-start path |
| 8 | `ZoneSuggestionNotifier leaves the active zone unchanged after a successful fix` | healthy fake, fix completes | zero `setActiveZone` calls | §4.4: suggests, never auto-switches. The single most important row in this task |
| 9 | `ZoneSuggestionNotifier writes the active zone when a suggestion row is tapped` | tap the row | one `setActiveZone` call with that zone code | The other half: the suggestion must actually be actionable |
| 10 | `ZonePickerScreen keeps every level interactive when the permission is denied` | `LocationEnv.denied` | all levels present, a sub-zone row tap still fires | §6 S9 and §14 say "fully usable"; asserting only that a message appeared would pass on a dead screen |
| 11 | `ZonePickerScreen states one line naming the reason when the permission is denied` | `LocationEnv.denied` | exactly one `LocationNotice`, carrying `zoneLocationDenied` | "One line saying why", counted so a second banner cannot creep in |
| 12 | `ZonePickerScreen states one line when location services are off` | `LocationEnv.servicesOff` | `zoneLocationServicesOff` | The distinct fact from case 5, on screen |
| 13 | `ZonePickerScreen states one line when the fix times out` | `LocationEnv.timesOut` | `zoneLocationTimedOut` | The 20 s outcome has to land somewhere the fisher can see |
| 14 | `ZonePickerScreen states one line when no bundled zone covers the fix` | healthy fix, `NoZoneMatched` | `zoneLocationNoZoneMatched` | The fourth kind of nothing; also the zero-polygon jurisdiction of T05 |
| 15 | `ZonePickerScreen renders one suggestion row per zone when the fix is ambiguous` | `ZoneAmbiguous` with two banks | two rows, neither pre-selected | T02 refuses to choose; this is where that refusal becomes visible |
| 16 | `ZonePickerScreen renders no suggestion row before a fix is requested` | fresh screen | none | A suggestion that appears unasked is an auto-switch with an extra step |
| 17 | `ZonePickerScreen shows no spinner, no accuracy readout and no signal indicator` | during and after a fix | none found | `chips-and-currency.md`'s banned copy and rule 9: a zone is chosen, never detected |
| 18 | `FakeLocationService reaches every LocationUnavailable subtype` | loop over `LocationEnv` | each subtype produced at least once, and the screen renders a line for each | The absence-of-a-failure-class test: adding an outcome forces the UI to handle it or the build goes red |
| 19 | `every location reason string is free of imperatives in all six locales` | the six ARB values | no banned-lexicon verb, no "settings", no "!" | Invariant 2, at the strings themselves |
| 20 | `ar - ZonePickerScreen renders the denied line from AppLocalizations` | locale `ar` | the Arabic string, no Latin literal | D-3 and `lonja-navigation-chrome` rule 4 |
| 21 | `locationServiceProvider throws until it is overridden` | bare `ProviderContainer` | `UnimplementedError` | `service-boundary-and-native` rule 5: a forgotten wiring must fail loudly, not return silent null data |
| 22 | `LocationService names no plugin type in its signatures` | static | no `geolocator` symbol outside `location_service_geolocator.dart` | Rule 3; the interface must be nameable from `domain/` |
| 23 | `the location feature contains no geocoding, map or network symbol` | grep over the feature and the service | nothing | §10's ban list and invariant 1, asserted rather than assumed |
| 24 | `the Android manifest declares no background-location permission` | parse `AndroidManifest.xml` | `ACCESS_BACKGROUND_LOCATION` absent | §14's static check; the built-AAB version is E21's |
| 25 | `Info.plist declares NSLocationWhenInUseUsageDescription and not the Always variant` | parse the plist | one present, one absent | §11 states both halves and §14 fails the build on the second |

```dart
// app/test/data/services/location_service_geolocator_test.dart
void main() {
  test('LocationServiceGeolocator returns LocationFixTimedOut after twenty seconds', () {
    fakeAsync((async) {
      final service = LocationServiceGeolocator(gateway: NeverAnsweringLocationGateway());
      LocationOutcome? outcome;

      unawaited(service.currentFix().then((o) => outcome = o));

      async.elapse(const Duration(seconds: 19));
      expect(outcome, isNull, reason: 'SPEC 13 budgets 20 s; giving up at 19 discards a valid fix');

      async.elapse(const Duration(seconds: 1));
      expect(outcome, isA<LocationFixTimedOut>());
      expect((outcome! as LocationFixTimedOut).seconds, 20);
    });
  });

  test('LocationServiceGeolocator requests the permission only inside currentFix', () {
    final gateway = RecordingLocationGateway();

    LocationServiceGeolocator(gateway: gateway); // constructed, never called

    expect(gateway.calls, isEmpty,
        reason: 'SPEC 11 defers every permission to first use, and a channel round trip at '
            'construction lands on the 1.2 s cold-start path');
  });
}
```

```dart
// app/test/ui/zones/zone_suggestion_test.dart
void main() {
  testWidgets('ZoneSuggestionNotifier leaves the active zone unchanged after a successful fix',
      (tester) async {
    final settings = FakeSettingsRepository();

    await tester.pumpZonePicker(
      settings: settings,
      location: FakeLocationService(LocationEnv.healthy),
      reference: kReferenceGaliciaAndSaoPaulo,
    );
    await tester.tap(find.byKey(const ValueKey('use-my-location')));
    await tester.pumpAndSettle();

    expect(find.byType(ZoneSuggestionRow), findsOneWidget);
    expect(settings.setActiveZoneCalls, isEmpty,
        reason: 'SPEC 4.4: suggests, never auto-switches');
  });

  testWidgets('ZonePickerScreen keeps every level interactive when the permission is denied',
      (tester) async {
    var tapped = false;

    await tester.pumpZonePicker(
      location: FakeLocationService(LocationEnv.denied),
      reference: kReferenceGaliciaAndSaoPaulo,
      onZoneTap: (_) => tapped = true,
    );
    await tester.tap(find.byKey(const ValueKey('use-my-location')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('zone-row-ES')));
    await tester.pumpAndSettle();

    expect(find.byType(ZoneLevel), findsNWidgets(3));
    expect(tapped, isTrue, reason: 'SPEC 6 S9: the manual list stays FULLY usable');
    expect(find.byType(LocationNotice), findsOneWidget);
  });
}
```

**Run:** `cd app && flutter test test/data/services/ test/ui/zones/ test/platform/` → 25 failures. If any
passes now, the test is wrong.

## Implementation outline

1. `location_service.dart`: the interface and the sealed family. `@useResult` on `currentFix`. Value
   types only — `LatLon` comes from `packages/rule_engine/`, not from the plugin.
2. `location_service_geolocator.dart`: a thin `LocationGateway` wrapping the plugin calls
   (`isLocationServiceEnabled`, `checkPermission`, `requestPermission`, `getCurrentPosition`) so the
   service itself is testable without a channel, then the service:
   services-off check → permission check → request if needed → `getCurrentPosition(
   locationSettings: LocationSettings(accuracy: LocationAccuracy.medium))` with
   `.timeout(const Duration(seconds: 20))`. Catch `TimeoutException` and `PlatformException` narrowly,
   log `(e, st)` **first**, then return the typed outcome. No bare catch.
3. `service_providers.dart`: `final locationServiceProvider = Provider<LocationService>((ref) => throw
   UnimplementedError('override locationServiceProvider in main.dart'));` and the single live override
   in `app/lib/main.dart`.
4. `fake_location_service.dart`: `implements LocationService`, a `switch` over `LocationEnv` with no
   `default:`, and `timesOut` returning `LocationFixTimedOut(seconds: 20)` synchronously so widget tests
   need no `fakeAsync`.
5. `zone_suggestion_view_model.dart`: `void requestFix()` owning
   `unawaited(_run().catchError(_record))`; `_run` awaits `currentFix()`, guards on `ref.mounted`,
   switches the outcome exhaustively, and on a `LocationFix` calls `LocateZone`. State holds the
   outcome and the `ZoneLookup`; nothing durable is written here.
   `void acceptSuggestion(String zoneCode)` — a **code**, never a row, per the stale-closure rule — is
   the only path to `SettingsRepository`.
6. `use_my_location_row.dart`, `zone_suggestion_row.dart` (glyph + word + colour, per
   `lonja-lists-and-tables` rule 9) and `location_notice.dart` (one line, `ink-muted`, no ground, no
   glyph).
7. Add the eight ARB keys to all six files and run E06's completeness check.
8. `pubspec.yaml` + the checked-in allowlist, in this commit. Android manifest, `Info.plist` and the six
   `InfoPlist.strings`.
9. Re-run the whole app suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 25 tests pass, and each failed first.
- [ ] `grep -rn 'geolocator' app/lib` matches exactly one file,
      `app/lib/data/services/location_service_geolocator.dart`.
- [ ] `grep -rnE 'getPositionStream|getLastKnownPosition|placemarkFrom|geocod' app/lib` returns nothing.
- [ ] The timeout is `const Duration(seconds: 20)` and the number appears once, next to a comment naming
      §13.
- [ ] `LocationOutcome` is switched exhaustively in the view model and in the widget, with no `default:`
      in either.
- [ ] No `LocationOutcome` subtype carries a user-facing string; each carries a stable `code`.
- [ ] `requestFix()` returns `void` and owns its own `unawaited(...).catchError(...)`; no `onTap: () =>
      notifier.requestFix()` arrow closure holds a `Future`.
- [ ] A successful fix performs zero writes to `user.db`, proved by a counting fake.
- [ ] With every `LocationUnavailable` subtype, all three levels render and a sub-zone row tap still
      fires its callback.
- [ ] The eight ARB keys exist in all six locales (D-3) and contain no imperative and no reference to a
      settings screen.
- [ ] `geolocator` is in the checked-in direct-dependency allowlist, added in this commit.
- [ ] `check_no_network.sh app/lib` and `check-service-boundaries.sh app/lib` are clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh       app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh           app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
$FLUTTER_SKILLS/service-boundary-and-native/scripts/check-service-boundaries.sh app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh   app/lib
$FLUTTER_SKILLS/state-management-riverpod/scripts/ban-legacy-providers.sh       app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(zones): take one GPS fix behind a typed service and offer a zone rather than switching

SPEC 4.4 says the fix suggests and never auto-switches, and SPEC 6 S9 says
the manual list stays FULLY usable with one line saying why when it cannot.
Both are asserted rather than described: a successful fix performs zero
writes to user.db until a suggestion row is tapped, and under every
unavailable outcome all three levels still render and a sub-zone tap still
fires.

Five ways this fails and each needs different words, so the service returns
a sealed LocationOutcome — a bool cannot tell "the fisher said no" from "the
receiver has no sky", and a throw is forgotten because Dart declares
nothing. The outcomes carry stable codes and no sentences; the words are ARB
keys in six locales.

Single-shot, user-initiated, 20 s, per SPEC 13's battery row: one
getCurrentPosition behind a timeout, no stream, and deliberately no
getLastKnownPosition — a cached fix can be hours old and a hundred
kilometres away and would suggest a zone with exactly the same confidence as
a live one. The permission is requested inside currentFix and nowhere else,
per SPEC 11's deferred-to-first-use rule and the 1.2 s cold-start path.

There is no route to the system settings screen: url_launcher and
AndroidIntent are grep-banned by SPEC 14, and "Open Settings" is an
instruction where the product states facts.

Task: E11/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
