# E05/T02 — Extraction: temp file, sha256, atomic rename

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): extract reference.db through a temp file, sha256 and an atomic rename` |
| **Depends on** | T01 (the executor takes a `File`; this task is what produces it) |
| **Size** | L |
| **Spec** | `SPEC.md` §7.4 bullet 1 and bullet 2; §13 (first launch < 6 s, determinate); §14 (force-quit during extraction) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Owns rule 6 — temp file plus atomic rename or it did not happen — and rule 7, the 6 s determinate budget. `references/extraction-and-first-launch.md` is the eight-step write sequence this task implements |
| `error-handling-typed-results` | The failure ladder is a sealed `Failure` family with stable codes and typed params, returned as `Result`, never a string and never a bare throw |
| `app-startup-and-bootstrap` | Rule 7 and rule 8: extraction is not on the launch path, and nothing about it is awaited in `main()` |
| `catchlaw-conventions-index` | Rule 8 (nothing awaited before `runApp`) and rule 1 (`rootBundle` is allowed; nothing else fetches bytes) |
| `testing-strategy` | Rule 5 (bare-`implements` fakes for the asset bundle and the directory seam) and `references/property-and-fakes.md`'s absence-of-a-failure-class shape, which is exactly what the force-quit test is |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.4 bullet 2 | "extracted to application support via a temp file plus atomic rename… A partial extraction leaves the temp file, which is deleted and retried on next launch" |
| `SPEC.md` | §13 row 1 | First launch < 6 s on a Snapdragon 665 **with a determinate progress indicator**, carved out of the interactive target |
| `SPEC.md` | §14 dynamic bullet 2 | "Force-quit **during** first-launch extraction; relaunch; extraction restarts cleanly and no corrupt DB is left behind" — the case this task turns into a test |
| `.claude/skills/catchlaw-reference-database/references/extraction-and-first-launch.md` | "The write sequence", "Progress and the budget", "Failure ladder" | The eight ordered steps with the state each leaves if killed; the 64 KiB reporting cadence; the response to each failure |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rules 6, 7, 10; "Temp file, atomic rename, orphan sweep" | The orphan sweep before anything else, and why the stamp is dropped before the write rather than after |
| `.claude/skills/catchlaw-reference-database/examples/reference_database.dart` | lines 83–135 | The worked installer. Note that D-6 replaces its `INSTALLED` stamp file — see "Why it is built this way" |
| `.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh` | check 4 | A file that decompresses and writes but never calls `.rename(` is a hard failure |
| `$FLUTTER_SKILLS/error-handling-typed-results/SKILL.md` | rules 3, 5, 6 | Stable `code` + typed params, log before returning, never swallow |
| `$FLUTTER_SKILLS/error-handling-typed-results/references/result-failure-spine.md` | "Failure taxonomy per boundary", "Convert-at-the-boundary" | The shape of the sealed family and where the `on`-clause catch goes |
| `$FLUTTER_SKILLS/app-startup-and-bootstrap/SKILL.md` | rules 7, 8; "The one blocker" | Extraction is not warm-up and is not a `main()` await |
| `FLUTTER_GUIDE.md` | §5.2 | The `LazyDatabase` callback is where the extraction gate lives |
| `epics/DECISIONS.md` | D-6 | All five mechanisms; this task is parts 1, 2 and 5 of them |

## What this delivers

- `app/lib/data/services/reference_installer.dart` — `ReferenceInstaller`, with
  `Future<Result<File, ReferenceInstallFailure>> ensureInstalled({void Function(int done, int total)?
  onProgress})`.
- `app/lib/data/services/reference_install_failure.dart` — the sealed family:
  `ReferenceAssetMissing` (`reference.asset_missing`, param `String assetKey`),
  `ReferencePayloadCorrupt` (`reference.payload_corrupt`, params `String expectedSha256, int
  expectedBytes, int actualBytes`), `ReferenceNoSpace` (`reference.no_space`, param `int neededBytes`),
  `ReferenceInstallIoFailed` (`reference.io_failed`, param `String step`).
- `app/lib/data/services/asset_bundle_service.dart` — `abstract interface class AssetBundleService` with
  `Stream<List<int>> openRead(String key)` and `RootBundleAssetService`, the only file in `app/lib/` that
  names `rootBundle`.
- `app/lib/data/services/app_directories.dart` — `abstract interface class AppDirectories` with
  `Future<Directory> reference()` and `Future<Directory> user()`, and `PathProviderDirectories` resolving
  both under `getApplicationSupportDirectory()`.
- `app/assets/db/reference.db.gz` produced by `tools/content_builder/`, listed under `assets:` in
  `app/pubspec.yaml`.
- `app/testing/fakes/fake_asset_bundle_service.dart` — a bare-`implements` fake driven by an
  `AssetEnv` enum, including an environment that throws part-way through the stream.
- `app/test/data/reference_installer_test.dart`.
- `crypto` added to `app/pubspec.yaml` and to the checked-in §14 direct-dependency allowlist.

## Why it is built this way

**Only `rename` is durable; everything before it is disposable.** `extraction-and-first-launch.md`
tabulates the state each of the eight steps leaves behind if the process dies there, and only one of
them is a state a later launch can misread: a truncated file at the live path. `File.rename` within one
directory is atomic on APFS and on ext4/f2fs, so the live path holds either the previous database or a
fully verified new one and never a prefix of one. That is the whole design. Writing straight to the live
path — the version anybody writes first — leaves a file that **opens cleanly** and answers with wrong
minimum lengths, which is worse than no database at all because the app still looks confident.

**The orphan sweep runs first, and the marker is cleared before the write, not after.** A `.tmp` in the
directory is evidence of a kill, so it is deleted rather than resumed: a resumed gunzip has no way to
know where the compressed stream left off. Clearing the completion marker before the first byte is
written is the subtle one — if the marker survived a failed extraction, a kill between the rename and
the marker write would be indistinguishable from success, and the app would trust a file it never
verified.

**Verification is sha256 *and* byte count.** The length check is nearly free and catches the truncation
class immediately; the hash catches the rest. Both are compared against values the content builder
emitted (T03 wires them; here they arrive as a constructor argument, which is what makes this task
testable without a build). A mismatch deletes the `.tmp` and retries **once** before failing — the
failure ladder's response, because a single bad read is more likely than a bad asset, and a retry loop
on a genuinely corrupt payload is a boot loop.

**Progress is determinate and its denominator is a real byte count.** `SPEC.md` §13 makes the
determinate indicator part of the requirement, not a nicety. The denominator is the uncompressed byte
count the builder measured, so the bar cannot finish at 94 % or run past 100 %; the callback fires at
most once per 64 KiB so it cannot itself become the cost. This task delivers the callback and nothing
visual — the bar, its copy and its non-dismissable disclaimer belong to `lonja-verdict-and-status` and
E12. **Never** a `CircularProgressIndicator`: six indeterminate seconds on a dark boat reads as a hang,
and a hang on first launch is the moment the app is deleted.

**The asset bundle and the directories are injected interfaces.** `rootBundle` needs a widget binding
and `path_provider` needs a platform channel; either one inside the installer would make every test in
this file a widget test and the force-quit case untestable. Two small ports (`testing-strategy` rule 5,
bare `implements`, no `noSuchMethod` superclass) keep the whole installer under `dart test`-speed
`flutter test` with a real temp directory and a fake bundle. The fake is driven by an enum so each
failure environment is a named case and adding one is a compile error.

**Rejected: `db.writeAsBytes(gzip.decode(bytes))`.** It is the shortest correct-looking implementation
and it is the anti-pattern the skill names twice. It writes to the live path, holds ~10 MB decompressed
in memory on a 2 GB device (`SPEC.md` §13's low-end row), and produces no progress at all.

**Rejected: the `INSTALLED` stamp file from the skill's worked example.** D-6 merged the two designs and
assigned the completion marker to `SPEC.md` §7.4's `app_meta.content_build_date` in `user.db`. This task
therefore takes a `MarkerStore` port — `Future<String?> read()` / `Future<void> write(String)` — and T03
supplies the `app_meta`-backed implementation. Two markers would be one too many, and the one that is
not written last is the one that lies.

**Rejected: catching everything.** `on FormatException` covers a corrupt gzip stream, `on
FileSystemException` covers the I/O ladder including `errno 28` (disk full), and `on FlutterError`
covers a missing asset. There is no bare `catch`; `check-swallowed-catch.sh` greps for one and
`error-handling-typed-results` rule 6 bans it. Each catch logs `(e, st)` **before** returning the typed
failure, because for an app that cannot phone home the local stack trace is the only diagnostic that
will ever exist.

## Tests first

Write every row before touching `reference_installer.dart`. Run them. **They must fail.** A test that
passes before the installer exists is asserting on the fake, not on the installer — fix the test first.

Every test runs against a real temp directory (`Directory.systemTemp.createTempSync`) and a
`FakeAssetBundleService`. The payload is a small real gzip of a real SQLite file so the sha256 and byte
count are genuine.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ReferenceInstaller.ensureInstalled extracts the payload on a first launch` | empty directory, no marker | `Ok`, `reference.db` present, sha256 matches | The base case, and the only one anybody writes unprompted |
| 2 | `ReferenceInstaller.ensureInstalled writes no bytes to the live path before the rename` | fake bundle pauses mid-stream | `reference.db` absent, `reference.db.tmp` present | The property the whole design exists to hold |
| 3 | `ReferenceInstaller.ensureInstalled deletes an orphan .tmp before extracting` | a 3-byte `reference.db.tmp` planted first | extraction succeeds, no `.tmp` afterwards | §14's force-quit case: the residue of a kill is swept, never resumed |
| 4 | `ReferenceInstaller.ensureInstalled leaves no openable database when the stream throws mid-extraction` | `AssetEnv.diesMidStream` | `Err(ReferenceInstallIoFailed)`, `reference.db` absent | The §14 sentence, verbatim: no corrupt DB is left behind |
| 5 | `ReferenceInstaller.ensureInstalled succeeds on the launch after a stream that died mid-extraction` | run 4, then a healthy run | `Ok`, sha256 matches | "extraction restarts cleanly" — the other half of §14, and the half that is usually skipped |
| 6 | `ReferenceInstaller.ensureInstalled keeps the previous database when a re-extraction dies mid-stream` | install v1, then `diesMidStream` for v2 | v1 file present and byte-identical | The failure ladder: a failed update never degrades the installed pack |
| 7 | `ReferenceInstaller.ensureInstalled clears the marker before writing the first byte` | marker set, `diesMidStream` | marker is `null` afterwards | Step 3 before step 4. If the marker survived, a kill between rename and marker would read as success |
| 8 | `ReferenceInstaller.ensureInstalled writes the marker only after the rename` | record marker writes and file renames in order | rename precedes marker write | Step 8 after step 7. A marker written first is a claim about a file that does not exist |
| 9 | `ReferenceInstaller.ensureInstalled returns ReferencePayloadCorrupt when the sha256 disagrees` | expected sha256 mutated | `Err(ReferencePayloadCorrupt)`, no `reference.db`, no `.tmp` | The check that makes the rename safe to trust |
| 10 | `ReferenceInstaller.ensureInstalled returns ReferencePayloadCorrupt when the byte count disagrees` | expected bytes mutated | same | Truncation is caught by length before the hash is even computed |
| 11 | `ReferenceInstaller.ensureInstalled retries once before reporting a corrupt payload` | corrupt on the first read, healthy on the second | `Ok`, bundle opened twice | The ladder says retry once. A retry loop on a genuinely bad asset is a boot loop |
| 12 | `ReferenceInstaller.ensureInstalled returns ReferenceAssetMissing when the asset is absent` | `AssetEnv.missing` | `Err(ReferenceAssetMissing)` with the asset key | Names the key so a mis-typed `pubspec.yaml` entry is one line to diagnose |
| 13 | `ReferenceInstaller.ensureInstalled returns ReferenceNoSpace with the bytes needed when the disk is full` | `FileSystemException` with `osError.errorCode` 28 | `Err(ReferenceNoSpace)` carrying the expected byte count | The user can act on "needs 41 MB"; they cannot act on "write failed" |
| 14 | `ReferenceInstaller.ensureInstalled reports progress against the payload byte count` | healthy run, collect callbacks | every `total` equals the expected byte count; final `done` equals it too | A denominator that is a guess is a bar that finishes at 94 %, which reads as "extraction is slow" |
| 15 | `ReferenceInstaller.ensureInstalled reports progress at most once per 64 KiB` | healthy run over a payload of n KiB | callback count ≤ `ceil(bytes / 65536)` | The reporting cadence is part of the budget, not decoration |
| 16 | `ReferenceInstaller.ensureInstalled creates the reference directory when it is absent` | delete the parent first | `Ok` | The genuine first launch: nothing under application support exists yet |
| 17 | `ReferenceInstaller.ensureInstalled leaves no .tmp behind on a successful run` | healthy run | directory holds `reference.db` only | An orphan that is never swept becomes ~41 MB of dead storage on the fisher's phone |
| 18 | `every AssetEnv either installs a verified database or returns a typed failure` | loop over `AssetEnv.detectable` | `Ok` with a matching sha256, or `Err` — never both false | The absence-of-a-failure-class test: silent loss here is a confident wrong answer |

```dart
// app/test/data/reference_installer_test.dart
import 'dart:io';

import 'package:catchlaw/data/services/reference_install_failure.dart';
import 'package:catchlaw/data/services/reference_installer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Err, Ok;

import '../../testing/fakes/fake_asset_bundle_service.dart';
import '../../testing/fakes/fake_marker_store.dart';
import '../../testing/models/reference_payload.dart'; // kTestPayloadGz, kTestPayloadSha256, kTestPayloadBytes

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('catchlaw_ref_'));
  tearDown(() => dir.deleteSync(recursive: true));

  ReferenceInstaller installerFor(AssetEnv env, {FakeMarkerStore? marker}) => ReferenceInstaller(
        bundle: FakeAssetBundleService(env, payload: kTestPayloadGz),
        directories: FixedDirectories(reference: dir),
        marker: marker ?? FakeMarkerStore(),
        expected: const ReferenceBuild(
          buildDate: '2026-07-14',
          bytes: kTestPayloadBytes,
          sha256: kTestPayloadSha256,
        ),
      );

  test('ReferenceInstaller.ensureInstalled deletes an orphan .tmp before extracting', () async {
    File('${dir.path}/reference.db.tmp').writeAsBytesSync([1, 2, 3]);

    final result = await installerFor(AssetEnv.healthy).ensureInstalled();

    expect(result, isA<Ok<File, ReferenceInstallFailure>>());
    expect(File('${dir.path}/reference.db.tmp').existsSync(), isFalse,
        reason: 'a .tmp is residue from a kill and is swept, never resumed');
  });

  test('ReferenceInstaller.ensureInstalled leaves no openable database when the stream throws mid-extraction',
      () async {
    final result = await installerFor(AssetEnv.diesMidStream).ensureInstalled();

    expect(result, isA<Err<File, ReferenceInstallFailure>>());
    expect(File('${dir.path}/reference.db').existsSync(), isFalse,
        reason: 'SPEC 14: a force-quit during extraction leaves no corrupt DB behind');
  });

  test('ReferenceInstaller.ensureInstalled succeeds on the launch after a stream that died mid-extraction',
      () async {
    await installerFor(AssetEnv.diesMidStream).ensureInstalled();

    final result = await installerFor(AssetEnv.healthy).ensureInstalled();

    expect(result, isA<Ok<File, ReferenceInstallFailure>>());
    expect(await sha256OfFile(File('${dir.path}/reference.db')), kTestPayloadSha256);
  });

  for (final env in AssetEnv.detectable) {
    test('$env: every AssetEnv either installs a verified database or returns a typed failure', () async {
      final result = await installerFor(env).ensureInstalled();
      final installed = File('${dir.path}/reference.db').existsSync() &&
          await sha256OfFile(File('${dir.path}/reference.db')) == kTestPayloadSha256;
      final surfaced = result is Err<File, ReferenceInstallFailure>;

      expect(installed || surfaced, isTrue,
          reason: 'SILENT LOSS under $env: neither a verified database nor a failure the UI can render');
    });
  }

  // … one test per remaining row above, one behaviour each
}
```

## Implementation outline

1. Add `crypto` to `app/pubspec.yaml` and to the §14 direct-dependency allowlist. Add the
   `assets/db/reference.db.gz` entry under `assets:`.
2. Write the two ports (`AssetBundleService`, `AppDirectories`) and the `MarkerStore` port, plus their
   live implementations. `RootBundleAssetService` is the only file naming `rootBundle`;
   `PathProviderDirectories` is the only one naming `getApplicationSupportDirectory`.
3. Write the sealed `ReferenceInstallFailure` family. Stable `code` on each, typed params, **no
   sentences** — the wording is E06's ARB work.
4. Write `ensureInstalled` as the gate plus `_extract`, in the eight-step order of
   `extraction-and-first-launch.md`: create the directory, sweep `*.tmp`, clear the marker, stream
   gunzip into `reference.db.tmp` reporting at most every 64 KiB, `flush()` then `close()`, verify
   length then sha256, `rename`, write the marker.
5. Bind the gunzip with `gzip.decoder.bind(stream)` over the bundle's byte stream so nothing holds the
   decompressed payload in memory.
6. Catch narrowly: `on FormatException` (corrupt stream), `on FileSystemException` (I/O, and
   `errorCode == 28` → `ReferenceNoSpace`), `on FlutterError` (missing asset). Log `(e, st)` first, then
   return the typed failure. Delete the `.tmp` in a `finally`-adjacent path so no failure leaves one.
7. Implement the single retry: on `ReferencePayloadCorrupt` from the first pass, delete the `.tmp` and
   run `_extract` once more; a second failure returns.
8. Write the fakes under `app/testing/fakes/` with the `AssetEnv` enum, including the
   `corruptButHashesClean` value documented as undetectable and excluded from `.detectable`.
9. Re-run the suite. 18 green, and T01's 16 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] The live path is written to exactly once per successful extraction, by `File.rename`.
- [ ] Check 4 of `check_reference_db.sh` is green — the file that decompresses also calls `.rename(`.
- [ ] No bare `catch`; every catch has an `on` clause and logs `(e, st)` before returning;
      `check-swallowed-catch.sh app/lib` is clean.
- [ ] No `ReferenceInstallFailure` subtype carries a user-facing string; every one carries a stable
      `code` and typed params.
- [ ] `rootBundle` appears in exactly one file; `getApplicationSupportDirectory` in exactly one.
- [ ] Nothing in this task is referenced from `app/lib/main.dart`; the installer is called from inside
      the `LazyDatabase` callback and nowhere else.
- [ ] `crypto` is in the checked-in §14 allowlist, and the allowlist diff check passes in CI.
- [ ] No `CircularProgressIndicator`, no indeterminate progress, and no string containing "Loading",
      "Downloading" or "Syncing" is introduced by this task.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh          app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): extract reference.db through a temp file, sha256 and an atomic rename

The eight-step write sequence from the reference-database skill: sweep any
orphan .tmp, clear the marker, stream the gunzip into reference.db.tmp with
determinate progress against a real byte count, flush, verify length then
sha256, rename, write the marker last. Only the rename is durable, so the
live path holds either the previous database or a fully verified new one.

SPEC 14's force-quit case is a test here, not a manual step: a stream that
dies mid-extraction leaves no openable database, the next launch sweeps the
residue and succeeds, and a failed update leaves the previously installed
pack byte-identical. Writing straight to the live path would leave a
truncated file that opens cleanly and answers with wrong minimum lengths.

The asset bundle, the support directory and the completion marker are
injected ports so the whole ladder is testable without a device.

Task: E05/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
