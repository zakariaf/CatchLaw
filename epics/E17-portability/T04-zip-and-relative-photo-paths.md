# E17/T04 — The zip, and relative photo paths

| | |
|---|---|
| **Epic** | E17 — Export and import |
| **Branch** | `epic/17-portability` (shared) |
| **Commit** | `feat(export): package the four artefacts as a zip and rewrite photo_path relative` |
| **Depends on** | T01 (the envelope), T02 (the CSV bytes), T03 (the PDF bytes) |
| **Size** | M |
| **Spec** | `SPEC.md` §12 export item 4, §4.5 (photos live inside the app sandbox), §11 (Android `getFilesDir()`, iOS Application Support), §13 (~200 KB per photo), §14 static check 1 (the direct-dependency allowlist) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `dependency-hygiene` | An archive writer is a direct dependency `SPEC.md` §10 does not list. This skill owns the add, the pin, the allowlist entry and the transitive audit that decides whether it may ship at all |
| `catchlaw-offline-guarantee` | `references/four-layers.md` layer 1 — the strongest layer is an absence, so a new package is audited for a networking edge *before* it is written into `pubspec.yaml`, not after |
| `service-boundary-and-native` | The archive writer touches the filesystem; `dart:io` `File` and `Directory` are the allowed half of the split |
| `error-handling-typed-results` | A missing photo file on disk is a named failure with the offending path, not an exception |
| `persistence-drift` | `photo_path` is a `user.db` column; the rewrite happens on the exported copy and never on the stored row |
| `testing-strategy` | Filesystem tests need a temp directory fixture and must clean up; no real photos in the repository |
| `naming-conventions` | The archive entry naming rule below is the load-bearing decision in this task |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, export item 4 | "Photos — optional; when included the export is a `.zip` containing the JSON, CSV, PDF and a `photos/` directory, with `photo_path` rewritten to relative paths" |
| `SPEC.md` | §4.5, "Photo handling" | In-app camera, images written inside the app sandbox, **never** the shared camera roll |
| `SPEC.md` | §11, Android and iOS | Where the sandbox actually is: `context.getFilesDir()` on Android, Application Support on iOS |
| `SPEC.md` | §13, "DB size at realistic usage" | ~200 KB per photo, 8,000 rows ≈ < 4 MB of records. The photos are the only real growth, which is why they are optional |
| `SPEC.md` | §14, static check 1 | The direct-dependency allowlist is diffed on every build; a new package is an allowlist edit in the same commit |
| `SPEC.md` | §14, dynamic | "Reinstall: confirm the catch log is gone … and that a pre-taken export restores it completely" — the line an absolute `photo_path` would fail |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 1 — the banned package table" | The list any candidate archive package is checked against, and the rule that the CLI's freedom to fetch does not extend to the app package |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 4 — the `dart:io` split" | `File`, `Directory`, `FileSystemEntity`, `FileMode`, `IOSink` are the allowed symbols; the export is named in that table as a reason they are allowed |
| `FLUTTER_GUIDE.md` | §1.4 | Services isolate data that lives outside Dart — the filesystem qualifies |
| `epics/DECISIONS.md` | D-1 | Paths: the app is at `app/`, and gate scripts are invoked with `app/lib` |

## What this delivers

- `app/lib/data/services/portability/export_archive_writer.dart` — `ExportArchiveWriter` with
  `Future<Failure<Uint8List>> write(ExportBundle bundle)`, producing the zip bytes.
- `app/lib/domain/models/portability/export_bundle.dart` — `ExportBundle`: the JSON string, the CSV
  bytes, the PDF bytes, and `List<ExportPhoto>` (`catchId`, `sourcePath`, `extension`).
- `app/lib/domain/use_cases/build_export_bundle.dart` — assembles the bundle, decides zip versus
  loose files, and performs the `photo_path` rewrite **on the exported envelope copy**.
- `app/lib/data/services/portability/export_file_names.dart` — the `catchlaw-export-YYYYMMDD.json`,
  `catches-YYYYMMDD.csv`, `trip-report-YYYYMMDD.pdf`, `catchlaw-export-YYYYMMDD.zip` naming, in one
  place.
- An archive package added to `app/pubspec.yaml` and to the checked-in direct-dependency allowlist.
- Tests: `app/test/data/services/portability/export_archive_writer_test.dart`,
  `app/test/domain/use_cases/build_export_bundle_test.dart`.

## Why it is built this way

**The archive dependency is audited before it is added, and the audit can veto the task.** Dart ships
no zip writer, and neither `pdf` nor `printing` provides one, so §12's `.zip` requires a package that
`SPEC.md` §10 does not list. Layer 1 in `four-layers.md` is "the dependency that does not exist" —
the strongest guarantee is an absence — so the order is: resolve the candidate, run
`flutter pub deps --style=compact`, and check every new edge against the banned package table. Only
then does it enter `pubspec.yaml`, the allowlist, and the `four-layers.md` transitive table. If the
candidate pulls any networking edge it is rejected outright and the fallback is in the epic's risks:
ship the three artefacts as loose files, lose the `photos/` directory, and raise a spec amendment. No
version number is written into this document because none has been verified here — `flutter pub add`
decides it, and the resolved version is what goes in the allowlist.

**Archive entries are named `photos/<catch_id>.<ext>`, not `photos/<basename>`.** Two catches
photographed a second apart can carry the same camera-generated basename, and a zip with two
identical entry names is a file where one photo silently overwrites the other. The catch id is unique
by construction (§7.2 `catch.id INTEGER PRIMARY KEY`), so the entry name is collision-free without a
counter, and the mapping back on import is a parse rather than a lookup. Rejected: hashing the file
contents into the name — it is stable and collision-free too, but it makes the zip unreadable to a
human opening it next to the CSV, and the CSV's photo column would carry a hash instead of something
a person can match to a row.

**`photo_path` is rewritten on the copy, never in `user.db`.** The exported envelope's catch rows get
`photos/12.jpg`; the stored row keeps its absolute sandbox path. Rewriting the database would break
every photo the app itself displays. The rewrite lives in the use case, on the value object, which is
possible only because `ExportedCatch` is immutable and `copyWith` produces a new value.

**Relative paths, because an absolute path never resolves after a restore.** On iOS the sandbox path
contains an install-specific UUID that changes on every reinstall; on Android the package data
directory changes across users and work profiles. §14's dynamic checklist has the line this protects:
"Reinstall: confirm the catch log is gone … and that a pre-taken export restores it completely". An
absolute `photo_path` would restore 8,000 rows all pointing at a directory that no longer exists, and
the failure would look like missing photos rather than a broken export.

**Photos are optional and the shape changes with them.** §12 is explicit: without photos the export
is the three files; with photos it is one zip containing all four things. So `BuildExportBundle`
returns either `LooseFiles(json, csv, pdf)` or `ZipArchive(bytes)` as a sealed result, and T05's share
sheet handles both. Rejected: always zipping — a fisher who wants to open the CSV on a laptop then
has to unzip first, and §13's numbers say the records are `< 4 MB` while the photos are the only real
growth. Making the common case a zip taxes the common case to serve the rare one.

**No compression on the photos.** JPEG is already compressed; deflating it again costs CPU on a
low-end device (§13: fully usable on 2 GB RAM, Android 7) and typically grows the file. The JSON, CSV
and PDF are deflated; the `photos/` entries are stored.

**A missing photo file is a named failure, not a silent skip.** If `photo_path` points at a file that
is gone — a bulk purge from S14 (E16), or a user clearing app data — the export names the catch id
and the path. Rejected: writing a zero-byte placeholder, which produces an export that looks complete
and restores broken photos.

## Tests first

Write every row before touching `export_archive_writer.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ExportArchiveWriter.write produces an archive containing the JSON, CSV and PDF entries` | bundle with no photos | three entries with the dated names | §12 names exactly these artefacts; a missing one is an incomplete export |
| 2 | `ExportArchiveWriter.write puts every photo under a photos/ directory` | 3 photos | entries `photos/…` | §12: "a `photos/` directory" |
| 3 | `ExportArchiveWriter.write names a photo entry by catch id` | catch 12, `IMG_0042.jpg` | entry `photos/12.jpg` | The collision rule; the whole reason this is not the basename |
| 4 | `ExportArchiveWriter.write keeps two photos with the same basename distinct` | catches 12 and 13, both `IMG_0042.jpg` | two entries, both present, both readable | The failure the naming rule exists to prevent, asserted directly |
| 5 | `ExportArchiveWriter.write stores photo entries without compression` | one JPEG fixture | entry's stored size equals the source size | §13 — CPU on a 2 GB Android 7 device, and deflate grows a JPEG |
| 6 | `ExportArchiveWriter.write returns a Failure naming the catch id when a photo file is missing` | `photo_path` pointing at a deleted file | `Failure` with `catchId: 12` and the path | A bulk purge (S14, E16) is a real state; a silent skip produces an export that restores broken |
| 7 | `BuildExportBundle rewrites photo_path to photos/<id>.<ext> in the exported envelope` | catch 12 with an absolute path | envelope's catch has `photos/12.jpg` | The rewrite §12 requires, on the copy |
| 8 | `BuildExportBundle leaves the stored catch row unchanged` | same input | the repository was never asked to write | Rewriting `user.db` would break every photo the app itself shows |
| 9 | `BuildExportBundle preserves the file extension` | `.png` and `.jpg` sources | `photos/12.png`, `photos/13.jpg` | A hardcoded `.jpg` makes a PNG unopenable after restore |
| 10 | `BuildExportBundle returns LooseFiles when no photos are included` | photos excluded | `LooseFiles`, three artefacts, no zip | §12: photos are optional, and the shape changes with them |
| 11 | `BuildExportBundle returns ZipArchive when photos are included` | photos included | `ZipArchive` | The other half of the same rule |
| 12 | `BuildExportBundle leaves photo_path null when the catch has no photo` | catch with null `photo_path` | still null in the envelope | Most catches have no photo; a `photos/12.` entry would be a dangling reference |
| 13 | `ExportFileNames.forDate builds the dated names from the local date` | 2026-08-01 | `catchlaw-export-20260801.json`, `catches-20260801.csv`, `trip-report-20260801.pdf` | §12 spells these names out; a fisher sorts his files by them |
| 14 | `ExportArchiveWriter.write produces an archive a reader can list without error` | full bundle, 3 photos | decode round trip lists 6 entries | The zip has to be readable by tools that are not this app — that is the point of the format |
| 15 | `BuildExportBundle round-trips a photo byte-for-byte` | 40 KB JPEG fixture | extracted bytes equal source bytes | An export that subtly corrupts a photo is worse than one that omits it |
| 16 | `ExportArchiveWriter.write writes no entry outside the archive root or photos/` | full bundle | no entry name contains `..` or starts with `/` | A zip-slip-shaped entry name would let a hand-edited export write outside the sandbox on import (T08) |

```dart
// app/test/data/services/portability/export_archive_writer_test.dart
import 'dart:io';

import 'package:catchlaw/data/services/portability/export_archive_writer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/models/portability_fixtures.dart';

void main() {
  late Directory temp;

  setUp(() async => temp = await Directory.systemTemp.createTemp('catchlaw_export_'));
  tearDown(() async => temp.delete(recursive: true));

  group('ExportArchiveWriter', () {
    test('.write names a photo entry by catch id', () async {
      final bundle = await bundleWithPhotos(temp, <int, String>{12: 'IMG_0042.jpg'});
      final result = await const ExportArchiveWriter().write(bundle);
      expect(entryNames((result as Ok<Uint8List>).value), contains('photos/12.jpg'));
    });

    test('.write keeps two photos with the same basename distinct', () async {
      final bundle = await bundleWithPhotos(temp, <int, String>{
        12: 'IMG_0042.jpg',
        13: 'IMG_0042.jpg',
      });
      final names = entryNames(
        ((await const ExportArchiveWriter().write(bundle)) as Ok<Uint8List>).value,
      );
      expect(names, containsAll(<String>['photos/12.jpg', 'photos/13.jpg']));
    });

    test('.write returns a Failure naming the catch id when a photo file is missing', () async {
      final bundle = bundleReferencingMissingPhoto(catchId: 12, path: '${temp.path}/gone.jpg');
      final result = await const ExportArchiveWriter().write(bundle);
      final failure = (result as Err<Uint8List>).failure as MissingPhotoFile;
      expect(failure.catchId, 12);
      expect(failure.path, endsWith('gone.jpg'));
    });

    test('.write writes no entry outside the archive root or photos/', () async {
      final bundle = await bundleWithPhotos(temp, <int, String>{12: 'IMG_0042.jpg'});
      final names = entryNames(
        ((await const ExportArchiveWriter().write(bundle)) as Ok<Uint8List>).value,
      );
      for (final name in names) {
        expect(name, isNot(contains('..')));
        expect(name, isNot(startsWith('/')));
      }
    });

    // … one test per row in the table above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/data/services/portability/export_archive_writer_test.dart` →
16 failures. If row 8 passes now, the test is wrong — it should be observing a fake repository that
does not yet exist.

## Implementation outline

1. **First, before any code:** resolve a candidate archive package, run
   `flutter pub deps --style=compact`, and check every new edge against
   `four-layers.md`'s banned package table. If a networking edge appears, stop and take the epic's
   documented fallback. Otherwise `flutter pub add` it, record the resolved version in the checked-in
   direct-dependency allowlist, and add a row to `four-layers.md`'s transitive table if it brings any
   new edge at all.
2. Write `ExportFileNames.forDate(DateTime)` — the four dated names, derived from the device's local
   date because that is the day the fisher will look for.
3. Write `ExportPhoto` and `ExportBundle`, and the sealed `ExportArtefacts` with `LooseFiles` and
   `ZipArchive`.
4. Write `ExportArchiveWriter.write`: add the three deflated entries, then each photo as a stored
   entry read through `File(...).readAsBytes()`. Missing file → `MissingPhotoFile(catchId, path)`.
5. Write `BuildExportBundle`: take the envelope from `ExportUserData` (T01), map each catch with a
   photo to `photos/<id>.<ext>` via `copyWith`, re-encode the JSON from the *rewritten* envelope, ask
   `CatchCsvWriter` (T02) for the CSV and `TripReportRenderer` (T03) for the PDF, and return
   `LooseFiles` or `ZipArchive` depending on the `includePhotos` flag.
6. Re-run the suite. All 16 green, and every T01–T03 test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] The archive package is in the checked-in direct-dependency allowlist with its resolved version,
      and `flutter pub deps --style=compact` shows it pulling no edge from the banned package table.
- [ ] `four-layers.md`'s transitive allowlist table is updated if, and only if, the package brings a
      new edge.
- [ ] No archive entry name can contain `..` or a leading `/` — asserted by test, because T08 will
      read these names back.
- [ ] `photo_path` in `user.db` is unchanged by an export — asserted by a fake repository that fails
      the test on any write.
- [ ] Photo entries are stored, not deflated.
- [ ] `export_archive_writer.dart` uses only `File`, `Directory` and `FileSystemEntity` from
      `dart:io` — no symbol from `four-layers.md`'s banned column.
- [ ] Line coverage on `export_archive_writer.dart` and `build_export_bundle.dart` is ≥ 90%.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
flutter pub deps --style=compact          # diff against the checked-in allowlist
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh        app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(export): package the four artefacts as a zip and rewrite photo_path relative

An absolute photo_path never resolves after a restore — the iOS sandbox path
carries an install-specific UUID and the Android data directory moves across
users — so §14's "a pre-taken export restores it completely" would fail with
8,000 rows pointing at a directory that no longer exists. Every photo is
rewritten to photos/<catch_id>.<ext> on the exported copy; the stored row is
untouched, because rewriting it would break every photo the app itself shows.

Entries are keyed by catch id rather than by camera basename: two catches a
second apart share a basename, and a zip with two identical entry names
silently loses one. Photos are stored rather than deflated — a JPEG is
already compressed and re-deflating it costs CPU on the 2 GB Android 7 device
§13 targets. Without photos the export stays three loose files, per §12.

The archive package was audited against four-layers.md's banned table and the
transitive graph before it entered pubspec.yaml, and is recorded in the
direct-dependency allowlist §14 diffs on every build.

Task: E17/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
