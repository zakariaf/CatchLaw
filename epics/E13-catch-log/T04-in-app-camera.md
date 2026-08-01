# E13/T04 — The in-app camera

| | |
|---|---|
| **Epic** | E13 — The catch log |
| **Branch** | `epic/13-catch-log` (shared) |
| **Commit** | `feat(log): capture catch photos inside the app sandbox, never the camera roll` |
| **Depends on** | T02 (`record()` and the `photo_path` column it currently writes NULL) |
| **Size** | L |
| **Spec** | `SPEC.md` §4.5 (Photo handling), §11 Android and iOS (permissions, app-private files, portrait), §10 (`camera` ^0.11; `image_picker` rejected), §13 (~200 KB per photo), §14 (deny camera permission: catches still recordable) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `service-boundary-and-native` | The whole task is one boundary: rules 1–8 and 10, plus `references/service-interface.md` for the sealed outcome, the hand-written fake, and checking every plugin return code by hand at the wire. |
| `error-handling-typed-results` | Rules 3, 4, 5: a denied permission is a typed value with a stable code, switched exhaustively with no `default:`, converted at the boundary after logging the original error. |
| `persistence-drift` | Rule 9: bytes never live in SQLite, the path is stored **relative** to a base directory and resolved at read time, and images are downscaled at import rather than at render. |
| `catchlaw-reference-database` | `references/two-database-contract.md`'s directory table — why Application Support and not Documents, Caches or external storage. |
| `catchlaw-conventions-index` | Invariant 1: a new direct dependency is the most common way a network edge arrives. `camera` is added to the §14 allowlist in this commit or CI fails on the next push. |
| `lonja-buttons` | Rules 8, 9, 11: the shutter is an icon-only control with a required `semanticLabel` in a 44 dp box, a disabled photo control states its reason in adjacent prose, and the handler latches. |
| `accessibility-as-code` | Rules 1, 2, 8: the capture surface is mostly unlabelled glyphs, which is exactly the case that locks out every screen-reader and switch user. |
| `state-management-riverpod` | Lifecycle: the controller is released in `ref.onDispose`, and the provider is `autoDispose` so leaving the screen frees the camera. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.5 row "Photo handling" | "In-app camera; images written inside the app sandbox. **Never** written to the shared camera roll" |
| `SPEC.md` | §10 rows `camera`, and the banned list | `camera` ^0.11, and `image_picker` banned by name for exactly this reason |
| `SPEC.md` | §11 Android | `CAMERA` optional and deferred to first use; **no storage permission** — scoped storage plus SAF via share; files in `getFilesDir()` |
| `SPEC.md` | §11 iOS | `NSCameraUsageDescription`, localised into all six languages; Application Support; portrait outside S3 and S13 |
| `SPEC.md` | §13 rows "DB size" and "Low-end devices" | ~200 KB per photo; no image caching beyond the visible grid |
| `SPEC.md` | §14 dynamic checklist | "Deny camera permission: catches still recordable without a photo" |
| `$FLUTTER_SKILLS/service-boundary-and-native/references/service-interface.md` | "Why a typed outcome", "Honest guarantees", "Check every return code by hand, at the wire" | The sealed-outcome table, the honest claim about what the type system does and does not catch, and the paranoia at the plugin boundary |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "Blobs are files on disk, paths relative" | The iOS container-UUID failure: the row survives, the file survives, the tile renders blank forever with no error |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Directories, and the ones that are wrong" | Documents is user-visible on iOS; Caches is purged without warning; external storage is writable by other apps |
| `.claude/skills/lonja-buttons/SKILL.md` | Rules 8, 9, 11 | `LonjaIconButton` requires `semanticLabel`; a disabled control explains itself; the latch |
| `FLUTTER_GUIDE.md` | Part 1.4 | Camera is a Service; "services are most helpful when the necessary data lives outside your Dart code" |
| `epics/DECISIONS.md` | D-3 | Six locales for the permission rationale: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` |

## What this delivers

- `app/lib/data/services/camera_service.dart` — `abstract interface class CameraService` and the
  sealed `CaptureResult`: `CaptureSucceeded(Uint8List jpeg)`, `CaptureCancelled`,
  `CaptureDenied(code)`, `CaptureUnavailable(code)`. Value types only; no `package:camera` symbol.
- `app/lib/data/services/camera/camera_gateway.dart` — the **only** file in the repository that
  imports `package:camera`. Wraps the controller, checks every return by hand, converts to the sealed
  outcome.
- `app/lib/data/services/photo_store.dart` — the single owner of the photo base directory,
  `<Application Support>/photos/`. `write(bytes, at:)` returns a **relative** path;
  `resolve(relativePath)` returns an absolute `File`. Nothing else builds a photo path.
- `app/testing/fakes/fake_camera_service.dart` — `implements`, with `succeeding`, `denied`,
  `cancelled` and `unavailable` constructors so every failure path is reachable.
- `app/lib/ui/log/capture_screen.dart` and `app/lib/ui/log/view_models/capture_view_model.dart`.
- `app/lib/ui/log/providers/camera_providers.dart` — `cameraServiceProvider`, throwing
  `UnimplementedError` until `app/lib/main.dart` overrides it; `photoStoreProvider`.
- `CatchDraft.photoPath` finally written by `record()` instead of NULL.
- `android/app/src/main/AndroidManifest.xml` — `android.permission.CAMERA`, and **no** storage
  permission of any kind.
- `ios/Runner/Info.plist` + `ios/Runner/<locale>.lproj/InfoPlist.strings` for all six locales of D-3 —
  `NSCameraUsageDescription` only.
- `app/lib/l10n/app_*.arb` ×6 — the in-app rationale, the denied-permission prose and every label on
  the capture surface.
- `camera` added to the checked-in direct-dependency allowlist that `SPEC.md` §14 diffs, in this same
  commit.
- Tests: `app/test/data/services/photo_store_test.dart`,
  `app/test/data/services/camera/camera_gateway_test.dart`,
  `app/test/ui/log/capture_screen_test.dart`,
  `app/integration_test/camera_capture_test.dart`.

## Why it is built this way

**`image_picker` is rejected and the reason is the whole feature.** `SPEC.md` §10 bans it by name:
its camera mode hands off to the system capture UI, and on both platforms the produced image lands in
the shared photo library — the camera roll — before the app ever sees it. §4.5 says **never**. An
in-app `CameraController` gives the app the frame in memory and lets it choose the only destination it
will ever use.

**There is no storage permission because there is nothing outside the sandbox to write.** §11 says so
in one line: *"No storage permission — scoped storage plus SAF via share."* The photo goes to
`getApplicationSupportDirectory()/photos/`, which on Android is `getFilesDir()` and on iOS is
Application Support. Documents is rejected because it is user-visible on iOS and the fisher can delete
a photo his own record points at; Caches is rejected because iOS purges it under storage pressure
without warning and without the app running; external storage is rejected because other apps can write
to it. That table is `two-database-contract.md`'s, and it applies to photo bytes for the same reasons.

**The stored path is relative and exactly one helper resolves it.** `persistence-drift` rule 9 names
the failure precisely: an absolute path dies on iOS reinstall or restore when the app-container UUID
changes — the row survives, the file survives, and the tile renders blank forever with no error and no
crash to report. `PhotoStore` owns the base directory; `photo_path` holds `photos/<name>.jpg` and
nothing longer. Test 4 below simulates the container change by resolving a path written under one base
directory against a different one.

**The file is written and flushed before the row that references it.** If the row went first and the
file write then failed, the record would point at nothing — the blank-tile failure above, permanent
and silent. Writing the file first means the crash window leaves an *orphan file*, which costs bytes
and nothing else, and T08's sweep reclaims it. This is the same ordering argument E17 records for its
Replace path: unlink last, always.

**A denied permission is a value, not an exception, and it never blocks a catch.** §14's dynamic
checklist has a line for it: *"Deny camera permission: catches still recordable without a photo."*
`CaptureDenied` is a sealed variant carrying a stable code and no localised string; the capture
control disables itself and one line of `ink-muted` prose beside it says what is missing
(`lonja-buttons` rule 9), while **Record without a photo** stays live. A dead grey control with no
explanation reads as a broken app, and a fisher who believes the app is broken keeps the fish.

**Every plugin return code is checked by hand at the wire.**
`service-interface.md` is blunt about the honest guarantee: a non-exhaustive `switch` over a sealed
outcome is a compile error, `@useResult` catches a discarded outcome as an analyzer diagnostic, and a
raw platform return code is caught by *nothing*. `camera` can report an initialisation failure through
a `CameraException` whose `code` is a plain string; the gateway maps each one explicitly and treats an
unrecognised code as `CaptureUnavailable(code)` rather than assuming success.

**Downscale at capture, not at render.** §13 budgets ~200 KB per photo and says the app must be fully
usable on 2 GB of RAM. A full-resolution frame from a modern sensor is several megabytes and would blow
both the storage figure T08 reports and the memory ceiling. The gateway requests a bounded resolution
preset and the store re-encodes to JPEG at a configured maximum edge before writing. **The exact
preset and quality are chosen by measurement on the reference device, not asserted here** — the unit
test asserts that the configured maximum edge is applied, and the byte budget is checked in the
integration test on hardware. Do not invent a number in the source.

**The controller is released on dispose and on background.** A held camera keeps the sensor powered,
which contradicts §13's "battery: negligible", and on Android a backgrounded app that keeps the camera
open is killed. `ref.onDispose` releases it, and the view model releases it on
`AppLifecycleState.inactive` and re-acquires on resume.

**Rejected:** content-addressed filenames with a `ref_count`, which `schema-and-daos.md` describes for
shared attachments. Here one catch owns at most one photo and `photo_path` is a single column; a
`ref_count` would add a table and a GC rule to solve a sharing problem the schema does not have. The
filename is derived from the injected clock, with a numeric suffix on collision, so it is deterministic
under `Clock.fixed`.

**Rejected:** capturing into a temporary file and moving it. The plugin already hands back bytes;
adding a temp hop adds a second crash window and a second orphan class for T08 to sweep.

## Tests first

Write every row before touching `camera_gateway.dart`. Run them. **They must fail.** A row that passes
now is testing nothing — fix the test first.

Unit tests use the hand-written `FakeCameraService` and a `PhotoStore` pointed at a temporary
directory; no emulator, no plugin, no real sensor. The one thing only hardware can prove — the byte
budget and that no image reaches the camera roll — is the integration test and the §14 device pass.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `PhotoStore.write puts the file under the application support directory` | 12 KB of bytes | file exists under `<support>/photos/` | The one-line mistake that puts a fisher's photo in Documents, where iOS shows it to him and lets him delete it |
| 2 | `PhotoStore.write returns a path relative to the photos base directory` | any write | `photos/2026-08-01T061200000Z.jpg`, no leading slash | An absolute path in the column is the defect; the return value is what gets stored |
| 3 | `PhotoStore.resolve joins a relative path onto the current base directory` | `photos/x.jpg` | an absolute `File` under the live base | The read half; if only one half is relative the feature works on the developer's machine and nowhere else |
| 4 | `PhotoStore.resolve finds a file written under a different container path` | write under base A, resolve under base B | the file at B | Simulates the iOS reinstall/restore container-UUID change — the exact failure `persistence-drift` rule 9 exists for, and it is silent |
| 5 | `PhotoStore.write appends a suffix when a file of that name already exists` | two writes at the same `Clock.fixed` instant | two files, both present | The clock-derived name collides on a burst; overwriting would destroy the first fish's photo |
| 6 | `PhotoStore.write applies the configured maximum edge` | a 4000 px fixture frame | written image's longest edge equals the configured maximum | §13's per-photo budget and the 2 GB RAM floor. Downscale at import, never at render |
| 7 | `PhotoStore.baseDirectory is the support directory, not documents` | — | path ends `Application Support/photos` | `two-database-contract.md`'s directory table, asserted rather than assumed |
| 8 | `CameraGateway returns CaptureDenied when the plugin reports a permission error` | fake plugin raising `CameraException('CameraAccessDenied')` | `CaptureDenied('CameraAccessDenied')` | The §14 line. A thrown exception here would reach a Notifier and become a crash instead of a state |
| 9 | `CameraGateway returns CaptureUnavailable with an unrecognised plugin code` | `CameraException('SomethingNew')` | `CaptureUnavailable('SomethingNew')` | `service-interface.md`: an unchecked return code is detected by nothing. Unknown must not fall through to success |
| 10 | `CameraGateway logs the original exception before returning a typed failure` | any plugin throw | logger called with `(e, st)` before the return | `error-handling-typed-results` rule 5 — this app cannot phone home, so the local stack trace is all there is |
| 11 | `CaptureViewModel surfaces the outcome <variant>` (loop over the four `CaptureResult` variants) | each variant | the matching UI state | Loop-generated with the variant interpolated (`CONVENTIONS.md` §5). A fifth variant must break the build |
| 12 | `CaptureScreen keeps Record without a photo enabled when permission is denied` | `FakeCameraService.denied()` | the record action is live | `SPEC.md` §14's dynamic line, as a test rather than a manual step |
| 13 | `CaptureScreen states what is missing beside the disabled photo control` | `FakeCameraService.denied()` | one line of prose naming the permission | `lonja-buttons` rule 9 — a dead grey control with no explanation reads as a broken app |
| 14 | `CaptureScreen labels the shutter control for a screen reader` | — | `isSemantics(label: …, isButton: true)`, box ≥ 44 dp | `accessibility-as-code` rules 2 and 8; an unlabelled glyph is silent to TalkBack and ambiguous to everyone |
| 15 | `FakeCameraService.denied returns CaptureDenied` | — | `CaptureDenied` | `service-boundary-and-native` rule 7 — a fake that always succeeds is a happy-path lie, so the failure path must be reachable by construction |
| 16 | `CatchLogRepository.record stores the relative photo path` | draft with a captured photo | `photo_path` = `photos/…jpg` | Closes T02's deliberate NULL |
| 17 | `CatchLogRepository.record leaves the photo file on disk when the insert fails` | forced constraint violation | file present, zero rows | The ordering argument: an orphan file costs bytes, a row pointing at nothing renders blank forever with no error |
| 18 | `CaptureViewModel releases the camera when the app is backgrounded` | `AppLifecycleState.inactive` | controller disposed | A held sensor contradicts §13's negligible-battery target and gets the app killed on Android |
| 19 | `CameraProviders dispose the controller when the capture route is popped` | pop | `ref.onDispose` ran | `state-management-riverpod` lifecycle; a leaked controller blocks the next capture |
| 20 | `Camera permission rationale exists in <locale>` (loop over `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`) | each ARB file | the key is present and non-empty | D-3. §11 requires the usage string localised into all six; a missing `ar` key shows English inside a permission prompt |

```dart
// app/test/data/services/photo_store_test.dart
void main() {
  test('PhotoStore.resolve finds a file written under a different container path', () async {
    final baseA = await Directory.systemTemp.createTemp('container-a');
    final baseB = await Directory.systemTemp.createTemp('container-b');

    final relative = await PhotoStore(baseDir: baseA).write(kJpegFixture, at: kT0);
    await File(p.join(baseA.path, relative)).copy(p.join(baseB.path, relative));

    final resolved = PhotoStore(baseDir: baseB).resolve(relative);
    expect(resolved.existsSync(), isTrue);          // the row survives a reinstall
    expect(relative, isNot(startsWith('/')));       // and nothing absolute was ever stored
  });
}
```

```dart
// app/test/data/services/camera/camera_gateway_test.dart
void main() {
  for (final result in <CaptureResult>[
    const CaptureSucceeded(kJpegFixture),
    const CaptureCancelled(),
    const CaptureDenied('CameraAccessDenied'),
    const CaptureUnavailable('SomethingNew'),
  ]) {
    testWidgets('CaptureViewModel surfaces the outcome ${result.runtimeType}', (tester) async {
      final container = ProviderContainer.test(overrides: [
        cameraServiceProvider.overrideWithValue(FakeCameraService(result)),
      ]);
      await container.read(captureViewModelProvider.notifier).shutter();
      expect(container.read(captureViewModelProvider), _expectedStateFor(result));
    });
  }
}
```

```dart
// app/test/ui/log/capture_screen_test.dart
testWidgets('CaptureScreen keeps Record without a photo enabled when permission is denied',
    (tester) async {
  await tester.pumpWidget(_harness(camera: FakeCameraService.denied()));

  final record = find.byKey(const Key('record-without-photo'));
  expect(tester.widget<LonjaButton>(record).onPressed, isNotNull); // SPEC §14
  expect(find.byKey(const Key('photo-unavailable-reason')), findsOneWidget);
});
```

**Run:** `cd app && flutter test test/data/services test/ui/log/capture_screen_test.dart` →
20 failures.

## Implementation outline

1. **Add `camera` to `app/pubspec.yaml` and to the checked-in allowlist in the same commit.** Then run
   `flutter pub deps --style=compact` and confirm the resolved graph adds no networking edge. §14
   permits `http` only as a transitive edge from exactly `printing` and `flutter_svg`; a third edge
   fails the build. Do this **first**, because if it fails nothing else in the task is worth writing.
2. `camera_service.dart` — the interface and the sealed outcome. No `package:camera` import, no
   `dart:io` symbol, no localised string anywhere in a failure.
3. `photo_store.dart` — base directory, `write`, `resolve`, and the name generator. It takes the base
   directory by constructor so tests point it at a temp dir; production wires
   `getApplicationSupportDirectory()`.
4. `camera_gateway.dart` — the live impl. Every `CameraException.code` mapped explicitly; unknown maps
   to `CaptureUnavailable`. Log `(e, st)` **before** returning. `@useResult` on the method.
5. `fake_camera_service.dart` — `implements`, four constructors, a call counter.
6. `camera_providers.dart` — `cameraServiceProvider` throws `UnimplementedError('override
   cameraServiceProvider in main.dart')`; `app/lib/main.dart` is the only place `CameraGateway` is
   constructed (`service-boundary-and-native` rules 5 and 6).
7. `capture_view_model.dart` — an `AsyncNotifier` over one immutable state value. The shutter handler
   is a `void` intent method that latches before its first `await`. It observes
   `AppLifecycleState` and releases the controller on `inactive`.
8. `capture_screen.dart` — portrait-locked (§11), one `LonjaIconButton` shutter with a required
   `semanticLabel`, one **Record without a photo** action, and the denied-permission prose beside the
   disabled control.
9. Wire `photoPath` into `CatchDraft` and into `record()`: file written and flushed, **then** the
   transaction.
10. Platform manifests and the six `InfoPlist.strings`. Confirm the release Android manifest still
    removes `INTERNET` (§11) and that no storage permission appears anywhere.
11. Re-run the whole suite. T02's test 15 asserted `photo_path` was NULL for a draft with no photo —
    that must still pass; a draft *with* a photo is the new case, not a replacement.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 tests pass, and each failed first.
- [ ] `grep -rn "image_picker" app/ android/ ios/` returns nothing.
- [ ] `grep -rln "package:camera" app/lib` returns exactly one path:
      `app/lib/data/services/camera/camera_gateway.dart`.
- [ ] `camera` appears in the checked-in allowlist, and `flutter pub deps --style=compact` shows no new
      `http`, `dio` or socket-opening edge.
- [ ] No `WRITE_EXTERNAL_STORAGE`, `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES` or
      `NSPhotoLibrary*UsageDescription` exists in any manifest or plist.
- [ ] `NSCameraUsageDescription` is present in all six `InfoPlist.strings` of D-3, and the in-app
      rationale key is present in all six ARB files.
- [ ] `photo_path` never holds an absolute path; `PhotoStore` is the only file that joins a photo path.
- [ ] The photo file is written and flushed before the transaction that references it opens.
- [ ] The capture route disposes its controller, and the app releases the camera on background.
- [ ] `cameraServiceProvider` throws until `main.dart` overrides it, and `main.dart` is the only file
      constructing `CameraGateway`.

## Gates

```bash
dart format --set-exit-if-changed .
cd app && flutter analyze && flutter test && cd ..
grep -rn "image_picker" app/ android/ ios/            # must return nothing
grep -rln "package:camera" app/lib                    # must return exactly one path
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                 app/lib
$FLUTTER_SKILLS/service-boundary-and-native/scripts/check-service-boundaries.sh app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh   app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh            app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(log): capture catch photos inside the app sandbox, never the camera roll

SPEC §10 bans image_picker by name and §4.5 gives the reason: its camera mode
hands off to the system capture UI, which writes the frame into the shared
photo library before the app ever sees it. An in-app CameraController gives us
the bytes and lets us choose the only destination we will ever use —
Application Support, which is app-private on both platforms. There is
therefore no storage permission at all.

photo_path stores a path RELATIVE to a base directory that one helper owns.
An absolute path dies on an iOS reinstall when the container UUID changes:
the row survives, the file survives, and the tile renders blank forever with
no error to report.

The file is written and flushed before the transaction that references it. The
other order leaves a row pointing at nothing, which is permanent and silent;
this order leaves an orphan file, which costs bytes and is reclaimed by T08.

A denied permission is a sealed value carrying a stable code, never a throw.
The photo control disables itself and says what is missing beside it, and
"Record without a photo" stays live — SPEC §14 tests exactly that.

Task: E13/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
