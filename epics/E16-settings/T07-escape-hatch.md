# E16/T07 — The escape hatch

| | |
|---|---|
| **Epic** | E16 — Settings |
| **Branch** | `epic/16-settings` (shared) |
| **Commit** | `feat(settings): show the user.db path and export the raw file` |
| **Depends on** | T01 (the repository), T06 (the storage section this row sits under) |
| **Size** | M |
| **Spec** | `SPEC.md` §12 ("Manual escape hatch: S14 shows the on-device path of `user.db` and offers 'Export raw database file', so a user can open their data in SQLite on a laptop without our cooperation"), §6 S14, §5.3 (URLs are selectable text; nothing is handed to a browser), §10 (`url_launcher` banned; `share_plus` is the file hand-off), §11 Android (files in `getFilesDir()`) / iOS (Application Support), §14 (the offline verification this export must survive) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | This is the app's only outbound path. The skill owns the full ban list and the argument for why a user-initiated share sheet is not a network call |
| `catchlaw-conventions-index` | Invariant 1 and rule 7 — `user.db` is the only irreplaceable file, and nothing in this diff may reach a network |
| `lonja-lists-and-tables` | The two rows this adds, and the mono type role the file path is set in |
| `lonja-buttons` | `secondary`, not primary and not destructive; a verb-first label naming the object; the busy latch so a double tap does not write two temp files |
| `persistence-drift` | `customStatement` for the checkpoint, and reopening the exported file in a test to read a row back |
| `service-boundary-and-native` | `share_plus` behind a service, so the share sheet is one seam E17 reuses rather than a call site |
| `async-safety` | The `mounted` guard after `await`, and the dropped-`Future` half of the busy latch |
| `error-handling-typed-results` | What the export returns when the copy fails, and how that surfaces without claiming a file was shared |
| `accessibility-as-code` | A selectable path must be reachable and readable by a screen reader as text, not announced as a link |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, "Manual escape hatch" | The entire requirement, verbatim, including "without our cooperation" — which is the acceptance condition, not decoration |
| `SPEC.md` | §12, Export (S15) | The four artefacts this is deliberately **not** one of, and the `catchlaw-…-YYYYMMDD` filename shape this follows |
| `SPEC.md` | §5.3, last bullet | "`authority_url` and `citation.source_url` are rendered as selectable text only. Nothing in the app hands a URL to a browser" — the same rule applied to a file path |
| `SPEC.md` | §10, "Explicitly banned" and the `share_plus` row | `url_launcher` is banned and `launchUrl` is grep-banned; `share_plus` is "the only outbound path, user-initiated and app-external" |
| `SPEC.md` | §11 Android / iOS | Where the file lives: `getFilesDir()` on Android, Application Support on iOS; `allowBackup="false"`, and `NSURLIsExcludedFromBackupKey` deliberately not set |
| `SPEC.md` | §14, Static and Dynamic | The grep list this diff must survive, and the airplane-mode export check this task extends by hand |
| `SPEC.md` | §7.4 | `user.db`'s schema version, which the row states so the exported file can be read confidently |
| `FLUTTER_GUIDE.md` | Part 1.4 | Services isolate data loading; the file system and the share sheet are each a service |
| `FLUTTER_GUIDE.md` | Part 5.2 | Databases open lazily; nothing is awaited before `runApp`, so the path is resolved on demand and never at startup |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §1, Allowed | "`Share.shareXFiles` for a user-initiated export" is on the allowed list; `url_launcher` is allowed only for `mailto:` and `tel:` on the about screen |
| `.claude/skills/lonja-buttons/SKILL.md` | Rules 2, 10, 11 | A verb label naming the object; busy is a latch and never a spinner; the handler is idempotent under rapid taps |
| `.claude/skills/lonja-buttons/references/button-anatomy.md` | "Label wording"; the approved corpus | `Export as CSV to this phone` sets the register this label matches; `Retry` and noun labels are listed failures |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | The ladder; "Busy: the 250ms rule" | `secondary` is "a real alternative path"; past 250 ms a 1.5 dp bottom rule, never a `CircularProgressIndicator` |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | The settings row; column classes | The mono role the path is set in, and the sub-line slot |
| `epics/DECISIONS.md` | D-1 | The app is at `app/`; the gates take `app/lib` explicitly |
| `epics/CONVENTIONS.md` | §5, §9 | Test naming; invariant 1, which this task comes closest to and does not weaken |

## What this delivers

- `app/lib/data/services/database_export_service.dart` — `DatabaseExportService`: resolve the path,
  checkpoint, copy to a temp file, hand the copy to the share sheet, delete the temp file when the
  sheet closes.
- `app/lib/ui/settings/widgets/settings_database_path_row.dart` — `SettingsDatabasePathRow`: a
  `SelectableText` of the absolute path in the mono role, plus a sub-line stating the file is a
  standard SQLite database and naming its schema version.
- `app/lib/ui/settings/widgets/settings_raw_export_row.dart` — `SettingsRawExportRow`: a
  `LonjaButton.secondary` labelled `Export the raw database file`, with the busy latch.
- ARB keys in all six locales: `settingsSectionYourData`, `settingsDatabasePathLabel`,
  `settingsDatabasePathDetail`, `actionExportRawDatabaseFile`, `settingsRawExportFailed`.
- `app/test/data/services/database_export_service_test.dart`,
  `app/test/ui/settings/settings_database_path_row_test.dart`,
  `app/test/ui/settings/settings_raw_export_row_test.dart`.

## Why it is built this way

**This is the feature that makes the no-cloud promise checkable.** `SPEC.md` §12 puts it in one
sentence: the user "can open their data in SQLite on a laptop **without our cooperation**". S17 states
that the app collects and transmits nothing; that is a claim. This screen hands over the file, so the
claim becomes something a person can verify with `sqlite3` and five minutes. Everything below follows
from that being the acceptance condition rather than a nice extra.

**The path is `SelectableText`, and nothing opens it.** `SPEC.md` §5.3 rules that `authority_url` and
`citation.source_url` are rendered as selectable text only, because handing a URL to a browser causes a
fetch under the browser's permission and defeats the Android guarantee. A file path is the same shape
of affordance. So: no "open in Files" intent, no `launchUrl`, no `AndroidIntent`, no `ACTION_VIEW` —
all four are on `SPEC.md` §14's static grep list and `url_launcher` is banned outright by §10.
**Rejected: a "Reveal in Files" action**, which would be the single most tempting line of code in this
epic and would fail the build.

**The share sheet is the one allowed outbound path.**
`catchlaw-conventions-index/references/product-invariants.md` §1's allowed list names
`Share.shareXFiles` for a user-initiated export explicitly. It is a hand-off to the OS, initiated by a
tap, carrying a file the user already owns; it fetches nothing and it opens no socket. `share_plus` is
already a direct dependency (`SPEC.md` §10) and its `url_launcher_platform_interface` edge is already
on §14's allowlist — this task adds no dependency. E17 reuses the same service for S15's four
artefacts.

**A copy is shared, never the live file.** Handing another application the path of a database drift has
open invites a reader mid-write, and on some platforms a share target copies lazily, long after the app
has moved on. So the export writes a temp file inside the app's own directory, shares that, and deletes
it when the sheet closes. **Rejected: `Share.shareXFiles([XFile(userDbPath)])`.**

**The copy is taken after a checkpoint.** A copy of an open SQLite database can miss writes that are
still in the write-ahead log, so the export runs `PRAGMA wal_checkpoint(TRUNCATE)` through drift's
`customStatement` before copying, and copies the `-wal` and `-shm` siblings if they still exist. No
claim is made here about drift's default journal mode — the test is the proof: row 1 writes a catch,
exports, reopens the exported file and reads the row back. If the checkpoint were removed, row 1 is
what fails.

**The filename follows §12's shape.** `catchlaw-user-YYYYMMDD.db`, matching
`catchlaw-export-YYYYMMDD.json`. The date is the export date in the device's own timezone, formatted
`yyyyMMdd` — a filename is not user-facing prose, so it stays ASCII and unlocalised while every date
*on screen* is locale-formatted per `SPEC.md` §9.5.

**`secondary`, and latched.** `variant-ladder-and-states.md`: `secondary` is "a real alternative path
the fisher may reasonably take" — S15's structured export is the other. Not `primary`, because the
screen has none. Not `destructive`, because nothing leaves the database. `lonja-buttons` rules 10 and
11: the handler guards on `_busy` before the first `await` so a bounced wet-finger tap does not produce
two temp files and two share sheets, and past 250 ms it draws a 1.5 dp bottom rule — never a spinner,
which on this screen would look exactly like the upload the app does not perform.

**The row states, it does not instruct.** The sub-line is a fact: the file is a standard SQLite
database, at schema version *n*, and nothing else is needed to read it. Not "Open it in DB Browser",
not "Copy this to your laptop".

## Tests first

Write every row before touching the service or either widget. Run them. **They must fail.** Row 1 in
particular must fail before the checkpoint exists — if it passes without one, the test is writing
through a path that never buffered, and the fixture is wrong.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `DatabaseExportService.export includes a row written immediately before the copy` | insert a catch, export, reopen the exported file | the catch is present | The whole correctness question. A copy taken without a checkpoint can miss the most recent writes, which is the export a user would notice last and trust least |
| 2 | `DatabaseExportService.export produces a file SQLite can open` | export | `NativeDatabase(File(exported))` opens and `PRAGMA integrity_check` returns `ok` | "Without our cooperation" means the artefact has to be a database, not a blob we can read |
| 3 | `DatabaseExportService.export names the file catchlaw-user-YYYYMMDD.db` | export on 2026-08-01 | `catchlaw-user-20260801.db` | §12's naming shape; a share sheet showing `temp_4821.db` is not a file anyone keeps |
| 4 | `DatabaseExportService.export shares a copy and not the live database file` | export | the shared path differs from the `user.db` path | Handing a share target a handle to a database drift is writing is the defect this avoids |
| 5 | `DatabaseExportService.export deletes the temporary copy when the sheet closes` | export, close the sheet | the temp file is gone | Otherwise every export doubles the database's footprint, on the same screen that reports the footprint |
| 6 | `DatabaseExportService.export leaves user.db unchanged` | export | the source file's bytes and mtime-independent contents are identical | An export that mutates the only irreplaceable file is the worst possible bug in this epic |
| 7 | `SettingsDatabasePathRow renders the resolved path as SelectableText` | pump | a `SelectableText` containing the application-support path | §5.3's rule applied to a path; a `Text` cannot be copied and a `TextButton` would invite a launcher |
| 8 | `SettingsDatabasePathRow renders no launcher affordance` | pump | no `GestureDetector` or button wrapping the path | `SPEC.md` §14's grep list bans `launchUrl`, `url_launcher`, `AndroidIntent` and `ACTION_VIEW`; this asserts the UI never grows one |
| 9 | `SettingsDatabasePathRow states the user_db schema version` | schema version 3 | the sub-line contains `3` | A database with an unnamed schema version is openable but not interpretable |
| 10 | `SettingsRawExportRow calls the export once when tapped twice within 90 ms` | double tap | one export | `lonja-buttons` rule 11 — two temp files and two share sheets from one bounced tap |
| 11 | `SettingsRawExportRow renders no CircularProgressIndicator while exporting` | pending export | none present, bottom rule after 250 ms | Rule 10 and `variant-ladder-and-states.md`; a spinner here reads as the upload this app does not do |
| 12 | `SettingsRawExportRow states the failure when the copy fails` | a service returning a failure | the failure line renders and no success is claimed | An export that silently does nothing is worse than one that fails loudly, on the feature whose entire job is trust |
| 13 | `RTL - SettingsDatabasePathRow keeps the path in logical order` | `ar` locale | the path's segments are not reordered | A left-to-right path inside a right-to-left paragraph needs bidi isolation, or `/data/user/0/…` renders scrambled and is uncopyable |
| 14 | `ar - SettingsRawExportRow renders its label from ARB` | `ar` | the `ar` string, not the `en` fallback | Six locales ship together (D-3); a missing key here falls back to English on the trust screen |
| 15 | `glove - SettingsRawExportRow measures 66 dp` | `gloveMode: true` | ≥ 66 | `variant-ladder-and-states.md`, Density |

```dart
// app/test/data/services/database_export_service_test.dart
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DatabaseExportService.export includes a row written immediately before the copy',
      () async {
    final dir = await Directory.systemTemp.createTemp('catchlaw_export');
    final source = File('${dir.path}/user.db');
    final db = UserDatabase(NativeDatabase(source));
    final share = RecordingShareService();

    await db.customStatement(
      "INSERT INTO \"catch\" (jurisdiction_code, zone_code, species_id, scientific_name, "
      "outcome, was_kept, created_at, updated_at) "
      "VALUES ('AE-RK','RAK-COAST',1,'Epinephelus coioides','meets',0,"
      "'2026-08-01T05:40:00','2026-08-01T05:40:00')",
    );

    await DatabaseExportService(database: db, share: share, now: () => DateTime(2026, 8, 1))
        .export();

    // Reopened as a plain file, exactly as sqlite3 on a laptop would.
    final exported = UserDatabase(NativeDatabase(File(share.sharedPaths.single)));
    final row = await exported
        .customSelect('SELECT scientific_name FROM "catch"')
        .getSingle();
    expect(row.read<String>('scientific_name'), 'Epinephelus coioides');

    await exported.close();
    await db.close();
    await dir.delete(recursive: true);
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/data/services/database_export_service_test.dart
test/ui/settings/settings_database_path_row_test.dart test/ui/settings/settings_raw_export_row_test.dart`
→ 15 failures. If any passes now, the test is wrong.

## Implementation outline

Only after the tests are red.

1. `database_export_service.dart`:
   - resolve the directory the same way `UserDatabaseService` does — one definition of where `user.db`
     lives, not two;
   - `await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)')`;
   - copy to `<temp>/catchlaw-user-YYYYMMDD.db` inside the app's own directory, plus the `-wal` and
     `-shm` siblings if they still exist;
   - `Share.shareXFiles([XFile(copy.path)])` behind a `ShareService` interface with a fake in
     `app/testing/fakes/`;
   - delete the copy in the `.whenComplete`, guarded so a failure to delete does not report a failed
     export;
   - return a typed result naming the failure, not a thrown exception.
2. `settings_database_path_row.dart` — mono `SelectableText`, bidi-isolated, plus the sub-line naming
   the schema version. No gesture, no button, no icon that looks like one.
3. `settings_raw_export_row.dart` — `LonjaButton.secondary` with the latched handler
   (`if (_busy) return;` before the first `await`, cleared in a `finally` gated on `mounted`).
4. Both into `SettingsScreen`'s final section, after T06's storage figures — the user reads what is
   stored, then how to take it.
5. Five ARB keys in six files (D-3).
6. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 15 rows pass, and each failed first.
- [ ] `grep -rnE "launchUrl|url_launcher|AndroidIntent|ACTION_VIEW|Uri\.https|Uri\.http" app/lib`
      returns nothing (`SPEC.md` §14 static list).
- [ ] `grep -rn "shareXFiles" app/lib` shows exactly one call site, inside `ShareService`.
- [ ] `grep -rn "getApplicationSupportDirectory\|getFilesDir" app/lib` shows the `user.db` directory
      resolved in one place, shared by `UserDatabaseService` and this service.
- [ ] `check_no_network.sh app/lib` clean, and the direct-dependency allowlist is unchanged by this
      commit — no dependency is added.
- [ ] **Manual, on device, in airplane mode:** tap `Export the raw database file`, confirm the share
      sheet appears, save the file, open it in a desktop SQLite client, and read back a catch recorded
      minutes earlier. `SPEC.md` §14's export line covers S15's four artefacts and does not name this
      fifth one — see the epic's Risk 3; E21 adds it to the checklist.
- [ ] The exported file's `PRAGMA user_version` matches the schema version the row states.
- [ ] `SettingsScreen` still builds zero `LonjaButtonVariant.primary`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh     app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh               app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh        app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
tools/gates/no_directional_geometry.sh                                    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(settings): show the user.db path and export the raw file

SPEC 12 asks for a hatch a user can leave through without our cooperation,
so this is the feature that turns S17's "we transmit nothing" from a claim
into something checkable with sqlite3 and five minutes.

The path is SelectableText and nothing opens it. SPEC 5.3 renders every URL
as selectable text because handing one to a browser causes a fetch under
the browser's permission; a file path is the same affordance, and
launchUrl, url_launcher, AndroidIntent and ACTION_VIEW are all on SPEC 14's
static grep list.

The export checkpoints through drift, copies to a temp file inside the
app's own directory, shares the copy, and deletes it when the sheet closes.
Sharing the live file hands a share target a handle to a database drift is
writing; skipping the checkpoint can drop the writes a user made minutes
ago, which is exactly the data they would check first. A test writes a
catch, exports, reopens the exported file as a plain SQLite database and
reads the row back.

No dependency is added: share_plus is already on the allowlist as the only
user-initiated, app-external outbound path.

Task: E16/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
