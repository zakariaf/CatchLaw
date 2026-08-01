# E05/T06 — Refuse a database from the future

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): refuse a user.db written by a newer build instead of corrupting it` |
| **Depends on** | T05 (the opener this check goes in front of) |
| **Size** | S |
| **Spec** | `SPEC.md` §7.4 bullet 4 — "The app refuses to open a `user.db` whose `schema_version` is *higher* than it understands and says so plainly, rather than corrupting it (this happens on downgrade)" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Rule 9 is this task verbatim: read `PRAGMA user_version` on a raw read-only handle before any drift access, throw `UserDbFromTheFutureFailure(found:, understood:)`, never delete and never "repair" |
| `error-handling-typed-results` | Rule 3: the failure carries a stable code and two typed integers, never a sentence. The wording is ARB work and belongs to E06 |
| `run-migration` | The reason the check must come first: reaching drift's `onUpgrade` already means drift has opened a file with columns it cannot see |
| `testing-strategy` | Rule 4: this is asserted against a real file on disk with a real `user_version`, not a stub |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.4 bullet 4 | The requirement, and the parenthesis that names the cause: downgrade |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rule 9; "Refusing a database from the future" | The raw-handle read, `OpenMode.readOnly`, both numbers on screen, never delete |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Refusing a database from the future" | The four-row action table (absent / 2 / 4 / 5) and the sentence that `reference.db` needs no equivalent check |
| `.claude/skills/catchlaw-reference-database/examples/reference_database.dart` | lines 50–81 | The worked `userExecutor()` with the version read before `NativeDatabase.createInBackground` |
| `$FLUTTER_SKILLS/error-handling-typed-results/SKILL.md` | rules 3, 4, 8 | Stable code, typed params, exhaustive switch, and the taxonomy of what may be thrown rather than returned |
| `$FLUTTER_SKILLS/error-handling-typed-results/references/result-failure-spine.md` | "Failure taxonomy per boundary", "Localization contract" | The `code` → gen-l10n mapping E06 will implement, and the `Failure × supportedLocales` exhaustiveness test that makes a missing translation a test failure |
| `FLUTTER_GUIDE.md` | §5.2 | The check lives inside the `LazyDatabase` callback, so it is off the first-frame path |
| `epics/DECISIONS.md` | D-3 | The plain message will exist in six locales: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` |

## What this delivers

- `app/lib/data/services/user_db_failure.dart` — `UserDbFromTheFutureFailure` with `final int found`,
  `final int understood`, `code => 'user_db.from_the_future'`, part of the `DataFailure` family T09
  completes.
- The version guard at the top of `openUserDatabase` in
  `app/lib/data/services/user_database_opener.dart`: a raw `sqlite3.open(path, mode:
  OpenMode.readOnly)`, one `PRAGMA user_version`, `raw.dispose()`, and the throw.
- `app/test/data/user_db_from_the_future_test.dart`.

## Why it is built this way

**The check must run before drift touches the file, because reaching `onUpgrade` is already too late.**
drift decides what to do from `user_version`; a value it does not know is a value its migration
machinery has no branch for, and whatever it does next it does with a schema definition that is missing
columns the file has. Writes then land in a table drift believes is narrower than it is. The read
therefore happens on a raw `sqlite3` handle, in `OpenMode.readOnly`, which cannot create a journal or a
`-shm` and cannot leave a trace — and the handle is disposed before drift is constructed.

**Refusal is the correct outcome, and deletion is not.** There is no account, no sync and no cloud
backup: `user.db` is the only copy of three seasons of trips. The user got here by installing an older
build over a newer one — a sideload, a reinstall from an old APK, a TestFlight rollback — and they can
undo it by updating. Deleting or "repairing" the file trades a fully recoverable situation for an
unrecoverable one. `catchlaw-reference-database` rule 9 and `two-database-contract.md` both say it: never
delete, never rename aside, never offer "reset".

**Both numbers are in the type.** `UserDbFromTheFutureFailure(found: 5, understood: 4)` is what lets the
screen say which build wrote the file and which build is reading it, and it is what lets a support
conversation resolve in one message. A boolean "too new" leaves the user with nothing to act on.

**The failure carries no sentence.** `error-handling-typed-results` rule 3: a baked-in message breaks
translation, RTL mirroring and numeral rendering — and this message will be read in Arabic on an RTL
layout with a numeral system §9.3 resolves per locale. The type carries a stable `code` and two typed
integers; E06 maps the code to an ARB key in all six locales of D-3, and the
`Failure × supportedLocales` exhaustiveness test makes a missing translation a test failure rather than
a blank screen.

**This is thrown, not returned.** `error-handling-typed-results` rule 8 draws the line at recoverable:
a downgrade is not a state the data layer can recover from, and every provider downstream of the
database is unusable. It is thrown from inside the `LazyDatabase` callback, surfaces as `AsyncError` on
the first provider that touches the database, and the app renders a refusal screen instead of the shell.
`ProviderScope(retry: (count, error) => null)` — set in the composition root by T09 — is what stops
Riverpod retrying it for ~38 s behind a spinner.

**`reference.db` gets no equivalent check, and that asymmetry is the design.** The reference file is
disposable: an older build simply sees a build-id mismatch in T03's gate and re-extracts its own payload
over it. Only the irreplaceable file gets a refusal.

**Rejected: comparing against `schemaVersion` instead of `understoodSchemaVersion`.** They are the same
number today, and `understoodSchemaVersion` is a `static const` that can be read without constructing a
database — which is what lets the guard run before drift exists. T04 makes `schemaVersion` return it so
there is one fact and not two.

**Rejected: reading the version through drift's own `customSelect`.** That requires a drift database,
which requires an open, which is the thing being guarded.

## Tests first

Write every row before touching the opener. Run them. **They must fail** — in particular row 3 will
"pass" trivially if it asserts only that the open throws, because a database from the future may throw
for unrelated reasons; assert the type **and** both numbers.

Each test writes a real file with `sqlite3.open`, sets `PRAGMA user_version = n`, closes it, and then
calls `openUserDatabase`.

| # | Test name | `user_version` on disk | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `openUserDatabase creates a database when the file is absent` | no file | opens; `user_version` = `understoodSchemaVersion` | The first-launch row of the contract's action table |
| 2 | `openUserDatabase opens a database at the understood version` | 1 | opens | The everyday path. If this throws, the guard's comparison is inverted |
| 3 | `openUserDatabase refuses a database one version ahead` | 2 | `UserDbFromTheFutureFailure(found: 2, understood: 1)` | The requirement, with both numbers asserted — a bare `throwsA` would pass on the wrong exception |
| 4 | `openUserDatabase refuses a database many versions ahead` | 99 | `UserDbFromTheFutureFailure(found: 99, understood: 1)` | A version jump across several releases; the `>` must not be an `==` |
| 5 | `openUserDatabase leaves the file byte-identical after a refusal` | 2 | sha256 and length unchanged | The whole point: this is the only copy that exists |
| 6 | `openUserDatabase leaves no -wal and no -shm after a refusal` | 2 | directory holds `user.db` only | Proof the raw handle was read-only and drift never opened the file |
| 7 | `openUserDatabase does not run a migration when it refuses` | 2, with a spy on `onUpgrade` | `onUpgrade` never invoked | Reaching `onUpgrade` means drift already opened a file with columns it cannot see |
| 8 | `openUserDatabase disposes the raw handle before drift opens the file` | 1 | handle closed first | A live raw handle during the drift open is a lock contention that appears as a random `SQLITE_BUSY` |
| 9 | `UserDbFromTheFutureFailure carries a stable code and no sentence` | — | `code` is `user_db.from_the_future`; no field is a user-facing string | Rule 3: a baked-in message cannot be translated, mirrored or renumbered |
| 10 | `openUserDatabase migrates a database behind the understood version` | 0 written as an older schema | migrates, no refusal | The `<` half of the comparison; a guard that refuses both directions bricks every update |

```dart
// app/test/data/user_db_from_the_future_test.dart
import 'dart:io';

import 'package:catchlaw/data/services/user_database_opener.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/data/services/user_db_failure.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('catchlaw_user_');
    file = File('${dir.path}/user.db');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  void writeDatabaseAtVersion(int version) {
    final raw = sqlite3.open(file.path);
    raw.execute('CREATE TABLE app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL) STRICT;');
    raw.execute('PRAGMA user_version = $version;');
    raw.dispose();
  }

  test('openUserDatabase refuses a database one version ahead', () async {
    writeDatabaseAtVersion(UserDatabase.understoodSchemaVersion + 1);

    await expectLater(
      openUserDatabase(file),
      throwsA(
        isA<UserDbFromTheFutureFailure>()
            .having((f) => f.found, 'found', UserDatabase.understoodSchemaVersion + 1)
            .having((f) => f.understood, 'understood', UserDatabase.understoodSchemaVersion),
      ),
    );
  });

  test('openUserDatabase leaves the file byte-identical after a refusal', () async {
    writeDatabaseAtVersion(UserDatabase.understoodSchemaVersion + 1);
    final before = (await sha256.bind(file.openRead()).first).toString();
    final lengthBefore = file.lengthSync();

    await openUserDatabase(file).then<void>((_) {}, onError: (_) {});

    expect((await sha256.bind(file.openRead()).first).toString(), before,
        reason: 'this is the only copy of the log that exists — never delete, never repair');
    expect(file.lengthSync(), lengthBefore);
  });

  test('openUserDatabase leaves no -wal and no -shm after a refusal', () async {
    writeDatabaseAtVersion(UserDatabase.understoodSchemaVersion + 1);

    await openUserDatabase(file).then<void>((_) {}, onError: (_) {});

    final names = dir.listSync().map((e) => e.path.split(Platform.pathSeparator).last).toList();
    expect(names, ['user.db'], reason: 'the version read must be read-only and drift must never open');
  });

  // … one test per remaining row above, one behaviour each
}
```

## Implementation outline

1. Write `UserDbFromTheFutureFailure` in `user_db_failure.dart`: `final class`, `const` constructor,
   two `final int` fields, a stable `code`, no `toString` that composes a user-facing sentence.
2. Put the guard at the very top of `openUserDatabase`, **before** the T05 snapshot: if the file exists,
   `sqlite3.open(file.path, mode: OpenMode.readOnly)`, read `PRAGMA user_version`, `dispose()` in a
   `finally`, and throw when the value exceeds `UserDatabase.understoodSchemaVersion`.
3. Leave `< understood` and `== understood` alone: the first falls through to T05's snapshot-and-migrate
   path, the second opens directly.
4. Add the refusal to the epic's follow-up list for E06 — one ARB key in six locales, with the two
   integers as ICU placeholders and Western digits per the citation convention.
5. Re-run the suite. 10 green, and T05's 15 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 10 tests pass, and each failed first.
- [ ] The version is read on a raw handle in `OpenMode.readOnly`, and the handle is disposed in a
      `finally` before drift is constructed.
- [ ] A refused file is byte-identical afterwards and has no `-wal` and no `-shm` beside it.
- [ ] `onUpgrade` is provably not reached on the refusal path.
- [ ] `UserDbFromTheFutureFailure` carries `found`, `understood` and a stable `code`, and no string a
      user would read.
- [ ] Nothing deletes, renames or truncates `user.db` anywhere in `app/lib/`.
- [ ] The guard is inside the `LazyDatabase` callback; `app/lib/main.dart` is unchanged.
- [ ] The comparison is `>`, and a database behind the understood version still migrates.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh     app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): refuse a user.db written by a newer build instead of corrupting it

SPEC 7.4 requires the app to refuse a user.db whose schema version exceeds
what it understands, and to say so plainly. The check reads PRAGMA
user_version on a raw read-only handle and disposes it before drift is
constructed: reaching drift's onUpgrade already means it has opened a file
with columns it cannot see, and the next write lands in a table it believes
is narrower than it is.

The file is never deleted, renamed aside or "repaired". This happens on a
downgrade, which the user can undo by updating — and user.db is the only
copy of three seasons of trips, with no account and no cloud backup behind
it. Tests assert the file is byte-identical after a refusal and that no -wal
or -shm appears beside it.

UserDbFromTheFutureFailure carries found, understood and a stable code and
no sentence; the wording is an ARB key in six locales and belongs to E06.

Task: E05/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
