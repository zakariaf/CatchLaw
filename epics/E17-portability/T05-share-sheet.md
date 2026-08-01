# E17/T05 — The share sheet

| | |
|---|---|
| **Epic** | E17 — Export and import |
| **Branch** | `epic/17-portability` (shared) |
| **Commit** | `feat(export): hand the export to the OS share sheet as the only outbound path` |
| **Depends on** | T04 (the artefacts must exist before anything can be shared) |
| **Size** | M |
| **Spec** | `SPEC.md` §12 ("Export (S15), via the system share sheet"), §5.3 (the accurate offline guarantee), §6 S15, §10 (`share_plus` row), §14 (static check 1; "the share sheet appears, in airplane mode") |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | The one task in the product that adds an outbound path. `references/four-layers.md` holds the `url_launcher_platform_interface` reasoning, the API grep list containing `launchUrl`, and layer 2 — the Android permission that makes the guarantee third-party checkable |
| `catchlaw-conventions-index` | `references/product-invariants.md` names `Share.shareXFiles` for a user-initiated export as explicitly allowed under invariant 1. That sentence is the authority for this whole task |
| `service-boundary-and-native` | `share_plus` is a platform-channel plugin; it goes behind a `ShareService` interface with a fake, or no test can run headless |
| `lonja-buttons` | S15's action ladder: one primary per screen, verb-phrase labels, the busy latch so a double tap does not build the export twice |
| `lonja-typography` | Every string on S15 comes from `LonjaType.of(context)`; the file-size line is a comparable numeral and takes mono tabular figures |
| `i18n-rtl-l10n` | The S15 ARB keys in six locales, directional geometry, and the file-size number's numeral system |
| `error-handling-typed-results` | A share cancelled by the user is a normal outcome, not a failure; a bundle that failed to build is |
| `state-management-riverpod` | `AsyncValue` carries the build-then-share sequence; never `AsyncValue<Result<T>>` (`FLUTTER_GUIDE.md` §1.7) |
| `dependency-hygiene` | `share_plus` and `file_picker` enter `pubspec.yaml` here, with the allowlist entry in the same commit |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, the export preamble | "**Export (S15)**, via the system share sheet" — the share sheet is the delivery mechanism, not an extra |
| `SPEC.md` | §5.3 | The whole section. Specifically: nothing hands a URL to a browser, because `ACTION_VIEW` would cause a fetch under the browser's own permission and defeat the Android guarantee |
| `SPEC.md` | §10, `share_plus` row | "Hand a file to the OS share sheet — the only outbound path, user-initiated and app-external. ⚠️ Pulls `url_launcher_platform_interface` transitively; on the exception list, and `launchUrl` is grep-banned" |
| `SPEC.md` | §14, static check 1 | "`url_launcher_platform_interface` only from `share_plus`. A third edge, or any direct `http`, fails" |
| `SPEC.md` | §14, dynamic | "Export produces all four artefacts and the share sheet appears, in airplane mode" — the device line this task sets up and E21 executes |
| `SPEC.md` | §6, S14 | Where S15 is entered from — the settings screen E16 already built |
| `SPEC.md` | §11, Android | Files in `context.getFilesDir()` (app-private); no storage permission — scoped storage plus SAF via share |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §1, "Allowed" | `rootBundle`, `getApplicationSupportDirectory()`, `Share.shareXFiles` for a user-initiated export; `url_launcher` **only** for `mailto:`/`tel:` on the about screen, never `https:` |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "The API grep list" | `launchUrl`, `launchUrlString`, `canLaunchUrl` are all failures inside `lib/` |
| `.claude/skills/catchlaw-offline-guarantee/SKILL.md` | rules 9, 11 | No URL is opened, launched, rendered or fetched; the UI offers no refresh, sync, retry or connectivity state |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | "The ladder", "Busy: the 250ms rule" | One primary; busy is a latch, never a spinner — and a spinner here would imply a network round trip that does not exist |
| `.claude/skills/lonja-buttons/SKILL.md` | rules 1, 2, 10, 11 | One primary per screen; verb-phrase labels; the latch that stops a bounced tap building two exports |
| `FLUTTER_GUIDE.md` | §1.4, §1.5 | A service per data source; abstract interface plus fake, `implements` not `extends` |
| `FLUTTER_GUIDE.md` | §1.7 | Skip `Command`; use `AsyncValue`, and never nest `AsyncValue<Result<T>>` |
| `epics/DECISIONS.md` | D-3 | Six locales for every ARB key added here |

## What this delivers

- `app/lib/data/services/portability/share_service.dart` — abstract `ShareService` with
  `Future<ShareOutcome> shareFiles(List<SharedFile> files, {required String subject})`, and
  `ShareOutcome { shared, dismissed, unavailable }`.
- `app/lib/data/services/portability/share_service_plus.dart` — the only file in the repository that
  imports `package:share_plus/share_plus.dart`, calling `Share.shareXFiles`.
- `app/lib/data/services/portability/export_staging.dart` — writes the artefacts to disk under a
  staging directory and returns their paths.
- `app/lib/ui/settings/export/export_screen.dart` and `export_view_model.dart` — S15.
- `app/testing/fakes/fake_share_service.dart` — records the paths handed to it and returns a
  configurable outcome.
- ARB keys in all six locales (D-3): `exportTitle`, `exportIncludePhotos`,
  `exportIncludePhotosExplainer`, `exportActionShare`, `exportActionSaveToThisPhone`,
  `exportEstimatedSize`, `exportNothingToExport`, `exportFailedTitle`, `exportShareUnavailable`.
- `share_plus` and `file_picker` added to `app/pubspec.yaml` and to the checked-in
  direct-dependency allowlist. (`file_picker` is `SPEC.md` §10's import mechanism and is consumed by
  T06; it lands here so a single allowlist edit covers both plugins.)
- Tests: `app/test/ui/settings/export/export_view_model_test.dart`,
  `app/test/data/services/portability/share_service_test.dart`,
  `app/integration_test/export_share_test.dart`.

## Why it is built this way

**This is the only outbound path in the product, and the sentence matters more than the code.** The
share sheet does not open a socket. It hands a file URI to the operating system, which shows a
picker, and the *user* chooses what happens next. It is user-initiated (nothing shares on a timer or
on app resume), app-external (the receiving app runs under its own permissions and its own consent),
and it carries nothing the user did not build by pressing a button.
`catchlaw-conventions-index/references/product-invariants.md` lists `Share.shareXFiles` for a
user-initiated export in the "Allowed" line of invariant 1, so this is not a carve-out being invented
here — it is the invariant as written. **Invariant 1 is not weakened by this task:** no code path in
`app/lib` can reach a socket, `check_no_network.sh app/lib` stays clean with no escape hatch, and on
Android the release manifest still denies `INTERNET` so the kernel would refuse a socket regardless.

**`url_launcher_platform_interface` arrives transitively, and `launchUrl` stays banned.** `share_plus`
depends on it for the platform-interface types. §14's static check 1 states the allowed shape
exactly: "`url_launcher_platform_interface` only from `share_plus`. A third edge, or any direct
`http`, fails." So the edge is expected, documented and diffed — and the API it would reach is in the
grep list. §5.3 gives the reason a URL is never launched: an `ACTION_VIEW` intent causes a fetch under
the *browser's* permission, which defeats the Android guarantee while leaving our own manifest
looking clean.

**One `ShareService` interface, one implementation, one import site.** `share_plus` is a platform
plugin; calling it from a widget makes S15 untestable without a device and puts a plugin type in the
UI layer. Behind the interface, `FakeShareService` records the paths and the widget test asserts the
four artefacts were handed over. Rejected: calling `Share.shareXFiles` from the view model — the view
model would then need `MethodChannel` mocking in every test, and `FLUTTER_GUIDE.md` §1.4 puts
anything living outside Dart code behind a service.

**Cancellation is an outcome, not a failure.** A fisher who opens the sheet and backs out has done
nothing wrong. `ShareOutcome.dismissed` is a named case the view model handles by returning to idle
with no message. Rejected: `bool` — the same argument `lonja-dialogs-and-surfaces` rule 2 makes about
dialogs applies here, and `false` would be indistinguishable from a platform failure.

**Artefacts are staged under `getTemporaryDirectory()` and are not deleted when the sheet closes.**
`Share.shareXFiles` completes when the sheet dismisses, but the receiving application may still be
reading the file — a mail client attaches by reference and copies lazily. Deleting on completion is a
race that produces a zero-byte attachment on a slow device. The OS reclaims the temporary directory,
and the next export overwrites the same dated filenames. **This is the one thing in the task that is
not verifiable from source:** whether `share_plus`'s bundled Android `FileProvider` declares a
`cache-path` covering that directory. It is in the epic's risks, the resolution is the E21 device
pass, and the documented fallback is `getApplicationSupportDirectory()/export/`, which `SPEC.md` §11
already names as the app-private location.

**Nothing on S15 mentions connectivity.** No "you are offline" note, no retry, no "sync". Rule 11 of
`catchlaw-offline-guarantee`: an affordance that cannot work teaches the fisher the app is broken at
the exact moment it is working as designed. The screen states what will be produced, its estimated
size, and one action.

**One primary action, and it is latched.** `lonja-buttons` rule 1: `Export and share` is the primary;
`Save to this phone` is secondary; the photo toggle is a control, not an action. Rule 11: the handler
guards on `_busy` before its first `await`, because building a 40-photo zip takes longer than a
bounced wet-finger tap and two taps would render the PDF twice. Rule 10: the busy affordance is the
bottom-edge rule after 250 ms, never a `CircularProgressIndicator` — a spinner in a 100% offline app
sends the user hunting for a signal.

## Tests first

Write every row before touching `share_service.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ExportViewModel.share hands every artefact path to the share service` | bundle with photos | fake recorded one `.zip` path | §14: "Export produces all four artefacts and the share sheet appears" — the artefacts must actually reach the sheet |
| 2 | `ExportViewModel.share hands three paths when photos are excluded` | photos off | fake recorded `.json`, `.csv`, `.pdf` | §12 — without photos the export is three loose files, not a zip |
| 3 | `ExportViewModel.share returns to idle when the user dismisses the sheet` | fake returns `dismissed` | state is `data`, no error surfaced | Backing out of a share sheet is normal behaviour, not an error worth a message |
| 4 | `ExportViewModel.share surfaces a failure when the bundle cannot be built` | fake bundle builder returns a `MissingPhotoFile` | `AsyncValue.error` naming the catch id | A half-built export must not reach the sheet looking complete |
| 5 | `ExportViewModel.share ignores a second tap while a share is in flight` | two rapid calls | share service called once | `lonja-buttons` rule 11 — a bounced tap on wet hands would render the PDF twice |
| 6 | `ExportViewModel.share writes the artefacts before calling the share service` | ordered fakes | staging write recorded before the share call | The sheet receives paths; handing it a path to a file not yet flushed is a zero-byte attachment |
| 7 | `ExportScreen builds exactly one primary action` | pump S15 | one `LonjaButtonVariant.primary` | `lonja-buttons` rule 1 |
| 8 | `ExportScreen shows no connectivity, retry or sync affordance` | pump S15 | no widget whose label matches retry/sync/offline/connect | `catchlaw-offline-guarantee` rule 11, asserted rather than trusted |
| 9 | `ExportScreen shows no CircularProgressIndicator while the export builds` | pump S15 mid-build | none in the tree | Rule 10, and a spinner here teaches distrust of an instant local answer |
| 10 | `ExportScreen states the estimated size before the export runs` | 17 catches, 3 photos | a size line is present | §13 puts photos at ~200 KB each; a fisher on a metered mail plan needs the number before he sends |
| 11 | `ExportScreen disables the share action with adjacent prose when there is nothing to export` | empty database | action disabled and a reason line rendered | `lonja-buttons` rule 9 — a dead control with no explanation reads as a broken app |
| 12 | `ar - ExportScreen renders every action label from ARB` | `ar` locale | no Latin-script literal in the action row | D-3 and rule 12 of `catchlaw-conventions-index` |
| 13 | `RTL - ExportScreen uses directional insets only` | `ar` locale | no `EdgeInsets.only(left:` or `right:` in the file | D-8 — the ban is a grep gate over `app/lib`, and this screen is new surface |
| 14 | `share_service_plus.dart is the only file importing package:share_plus` | tree scan of `app/lib` | exactly one match | The boundary that lets every other test run headless, and lets the plugin be swapped |
| 15 | `No file under app/lib references launchUrl, launchUrlString or canLaunchUrl` | tree scan | no match | §5.3 and the API grep list — the transitive `url_launcher_platform_interface` edge must stay unreachable |
| 16 | `ShareOutcome has a named case for dismissal` | enum | `dismissed` exists and is handled in every `switch` | The `bool?` collapse `lonja-dialogs-and-surfaces` rule 2 forbids, applied to a service result |

```dart
// app/test/ui/settings/export/export_view_model_test.dart
import 'package:catchlaw/data/services/portability/share_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/fake_share_service.dart';
import '../../../../testing/models/portability_fixtures.dart';

void main() {
  group('ExportViewModel', () {
    test('.share hands every artefact path to the share service', () async {
      final share = FakeShareService(outcome: ShareOutcome.shared);
      final vm = buildExportViewModel(share: share, bundle: kBundleWithThreePhotos);

      await vm.share();

      expect(share.receivedPaths, hasLength(1));
      expect(share.receivedPaths.single, endsWith('.zip'));
    });

    test('.share ignores a second tap while a share is in flight', () async {
      final share = FakeShareService(outcome: ShareOutcome.shared, delay: kShortDelay);
      final vm = buildExportViewModel(share: share, bundle: kBundleWithThreePhotos);

      await Future.wait(<Future<void>>[vm.share(), vm.share()]);

      expect(share.callCount, 1);
    });

    test('.share returns to idle when the user dismisses the sheet', () async {
      final vm = buildExportViewModel(
        share: FakeShareService(outcome: ShareOutcome.dismissed),
        bundle: kBundleWithThreePhotos,
      );

      await vm.share();

      expect(vm.state.hasError, isFalse);
    });
  });

  group('outbound path guard', () {
    test('share_service_plus.dart is the only file importing package:share_plus', () {
      final offenders = dartFilesUnder('lib')
          .where((f) => f.readAsStringSync().contains("package:share_plus/"))
          .map((f) => f.path)
          .toList();
      expect(offenders, <String>['lib/data/services/portability/share_service_plus.dart']);
    });

    test('No file under app/lib references launchUrl, launchUrlString or canLaunchUrl', () {
      final offenders = dartFilesUnder('lib')
          .where((f) => RegExp(r'\b(launchUrl|launchUrlString|canLaunchUrl)\b')
              .hasMatch(f.readAsStringSync()))
          .map((f) => f.path);
      expect(offenders, isEmpty);
    });
  });

  // … one test per row in the table above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/settings/export/ test/data/services/portability/share_service_test.dart`
→ 16 failures. If row 15 passes now, the test is wrong: it must be walking real files, and a scan
that finds no files at all reports success — the failure mode `CONVENTIONS.md` §7 warns about. Assert
the walk found a non-empty file list before asserting the matches are empty.

## Implementation outline

1. `flutter pub add share_plus file_picker`. Record both resolved versions in the checked-in
   direct-dependency allowlist. Run `flutter pub deps --style=compact` and confirm
   `url_launcher_platform_interface` has exactly one root, `share_plus`, and that no third `http`
   edge appeared (§14 static check 1).
2. Write `ShareService`, `SharedFile`, `ShareOutcome` and `FakeShareService`. The interface takes
   paths and a subject; it takes no `BuildContext` and no `XFile`.
3. Write `ShareServicePlus` — `Share.shareXFiles([...])`, mapping `ShareResultStatus` to
   `ShareOutcome`. This file imports `package:share_plus/share_plus.dart` and nothing else does.
4. Write `ExportStaging`: `getTemporaryDirectory()` → `catchlaw_export/`, write the artefacts, flush
   and close every sink before returning the paths. Do not delete on completion; say why in a comment
   that names the lazy-copying mail client.
5. Write `ExportViewModel` on `AsyncNotifier`: build the bundle (T04), stage it, share it. `_busy`
   guard before the first `await`. No `AsyncValue<Result<T>>` (`FLUTTER_GUIDE.md` §1.7) — unwrap the
   failure and set `AsyncValue.error`.
6. Write `ExportScreen`: title, a photo-inclusion switch with its explainer, the estimated size line
   in mono tabular figures, one primary `Export and share`, one secondary `Save to this phone`. Every
   label from ARB, every inset directional.
7. Add the nine ARB keys to all six locale files (D-3) and run `gen-l10n`.
8. Write `app/integration_test/export_share_test.dart` — drive S14 → S15 → tap the primary, with a
   fake share service injected via a provider override, and assert the four artefacts exist on disk.
   The airplane-mode half of §14 is a device check and belongs to E21; this test does not claim it.
9. Re-run the suite. All 16 green, and `check_no_network.sh app/lib` clean.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] `share_plus` and `file_picker` are in the checked-in direct-dependency allowlist, and
      `flutter pub deps --style=compact` shows `url_launcher_platform_interface` reachable from
      exactly one root, `share_plus`.
- [ ] `grep -rn "launchUrl\|url_launcher\|canLaunchUrl" app/lib` returns nothing.
- [ ] `package:share_plus` is imported by exactly one file in `app/lib`.
- [ ] `ShareOutcome.dismissed` is a handled case in every `switch` over it; no `bool` crosses the
      service boundary.
- [ ] S15 renders exactly one primary action, and its handler is latched before the first `await`.
- [ ] S15 contains no `CircularProgressIndicator`, no connectivity check and no retry affordance.
- [ ] The nine ARB keys exist in all six locales, and the E06 completeness check is green.
- [ ] `check_lonja_buttons.sh app/lib` and `check_lonja_type.sh app/lib` are clean.
- [ ] The commit body records that invariant 1 was reviewed and is unweakened.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
flutter pub deps --style=compact          # diff against the checked-in allowlist
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh        app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                  app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                  app/lib
tools/gates/no_directional_geometry.sh                                       app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(export): hand the export to the OS share sheet as the only outbound path

Share.shareXFiles opens no socket. It hands a file URI to the operating
system and the user chooses what happens next: user-initiated, app-external,
carrying only what he built by pressing a button. product-invariants.md names
it in the "Allowed" line of invariant 1, so this is the invariant as written
rather than a carve-out invented here — check_no_network.sh stays clean over
app/lib with no escape hatch, and the release manifest still denies INTERNET.

share_plus pulls url_launcher_platform_interface, which §14 static check 1
allows from exactly that one root; launchUrl, launchUrlString and canLaunchUrl
are absent from app/lib and a test walks the tree to prove it, because §5.3's
reason is specific — an ACTION_VIEW intent fetches under the browser's own
permission and defeats the Android guarantee while our manifest still looks
clean.

The plugin sits behind ShareService with a recording fake, so S15 is testable
headless and the plugin is one file to replace. Staged artefacts are not
deleted when the sheet closes: a mail client attaches by reference and copies
lazily, and deleting on completion is a race that produces a zero-byte
attachment.

Task: E17/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
