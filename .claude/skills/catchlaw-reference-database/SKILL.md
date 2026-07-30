---
name: catchlaw-reference-database
description: >-
  Governs CatchLaw's two-database split and the pre-seeded reference asset — reference.db read-only
  and replaced wholesale, user.db writable and migrated forward-only, LazyDatabase over
  NativeDatabase.createInBackground readOnly, the assets/db/reference.db.gz payload, its
  reference.build.json sidecar and a generated kReferenceBuildId, an INSTALLED stamp over the
  circular content_meta read, temp-file plus atomic rename with orphan sweep and sha256 check, a
  6-second determinate first-launch budget outside the 1.2-second cold start, catch rows
  denormalising scientific_name, citation_text and content_version, and refusal when user_version
  exceeds schemaVersion. Use when writing ReferenceDatabase or ReferenceInstaller, awaiting an open
  near runApp, replacing the shipped rule pack, adding a column to catches, bumping schemaVersion,
  picking a path_provider directory, reaching for ATTACH, or reviewing first-launch progress.
---

# CatchLaw Reference Database

CatchLaw ships two SQLite files with opposite lifecycles. `reference.db` is CONTENT — pre-seeded at build time by the content tool, opened read-only, never migrated, disposable, and replaced wholesale on update. `user.db` is the fisher's own RECORD — writable, migrated forward-only, never touched by a content update. This skill owns that split, the asset extraction contract and the first-launch budget. It does not own Drift itself.

Read the reference for the task at hand:
- `references/two-database-contract.md` — the file/table split, ownership matrix, directory and backup policy, denormalised catch columns, `user_version` refusal, the ATTACH ban.
- `references/extraction-and-first-launch.md` — the circular build-date check, sidecar asset and generated constant, temp plus atomic rename, orphan sweep, sha256 verification, progress budget, failure ladder.

Run `scripts/check_reference_db.sh` before a PR.

Drift mechanics — `@DriftDatabase` wiring, DAO shape, transactions, keyset pagination, generated `*.drift.dart` — live in `persistence-drift`; the forward-only migration ritual and `MigrationStrategy` steps live in `run-migration`; `build_runner` invocation lives in `codegen-and-toolchain`; how the content tool BUILDS `reference.db` lives in `catchlaw-content-pipeline`. This skill owns only what is unique to shipping TWO databases, one of which is content.

## Non-negotiable rules

1. **Two databases, two lifecycles, and NEVER one file.** `reference.db` holds `species`, `zones`, `rules`, `citations`, `content_meta`; `user.db` holds `trips`, `catches`, `settings`. No table crosses. **WHY:** the moment the fisher's catch log lives in the same file as content, a rule-pack update is a write against his records — and the failure mode is not a bad verdict, it is three seasons of trip history destroyed by a routine content drop.

2. **NOTHING awaits a database open before `runApp`.** Both are `LazyDatabase(() async …)`; `main()` calls `WidgetsFlutterBinding.ensureInitialized()`, builds providers and calls `runApp` synchronously. An `await ref.read(userDatabaseProvider).…` above `runApp` fails `scripts/check_reference_db.sh`. **WHY:** an awaited open puts a cold `sqlite3_open` plus page-cache warm-up on the critical path and blows the 1.2 s cold-start target on a five-year-old Android — a black screen with a fish in the bin.

3. **`reference.db` opens READ-ONLY and registers no migration.** `NativeDatabase.createInBackground(file, readOnly: true)`, and its `MigrationStrategy` is `onCreate`/`onUpgrade` callbacks that THROW `StateError('reference.db is never migrated')`. **WHY:** a writable open lets Drift silently run `onCreate` against a shipped asset and a WAL/journal file appears next to it, so the sha256 no longer matches and every subsequent integrity check is a false alarm.

4. **A content update REPLACES `reference.db` wholesale; it never patches it.** New payload, new extraction, atomic rename over the old file, old file deleted. No `INSERT`, no `UPDATE`, no `ALTER TABLE`, no `schemaVersion` bump. **WHY:** an incrementally patched reference DB has no single provenance — you can no longer state which build produced the row that failed the fish, and rule 8's `content_version` on the catch row becomes a lie.

5. **The build id ships as a SIDECAR asset and a generated Dart constant, never read from `content_meta`.** `assets/db/reference.build.json` (under 200 B) plus `kReferenceBuildId`, `kReferenceBytes` and `kReferenceSha256` in `lib/data/reference/reference_build.g.dart`. **WHY:** reading `content_meta.build_id` from the shipped DB requires materialising and opening it — the exact 4-second job the check exists to skip — so the naive "compare build_date" gate is CIRCULAR and re-extracts on every single launch.

6. **Extraction is temp file plus ATOMIC RENAME, or it did not happen.** Decompress to `reference.db.tmp`, `flush()`, verify sha256 and byte count, `File.rename()` onto `reference.db`, then write the `INSTALLED` stamp. Any `*.tmp` found at startup is DELETED before extraction begins. **WHY:** a kill at 80 % leaves a truncated file that opens cleanly and returns wrong minimum lengths — a half-written rule pack is worse than none, because the app still looks confident.

7. **First launch gets its own budget: under 6 s with a DETERMINATE bar, explicitly outside the 1.2 s target.** Progress is driven by `kReferenceBytes` from the sidecar, reported at most every 64 KiB, and the copy states the fact — "Preparing the rule book · 62 %" — never "Loading…", never a spinner. **WHY:** an indeterminate spinner over a six-second job on a dark boat reads as a hang, and a hang on first launch is the moment the app is deleted.

8. **A `catches` row DENORMALISES what it was judged under.** `scientific_name`, `common_name`, `citation_text`, `content_version`, `method` (`TL`/`FL`/`CW`/`SHL`), `measured_mm`, `judged_at` are COPIED onto the row — never a foreign key into `reference.db`. **WHY:** a content update retires rules; a three-year-old record joined live against today's pack would restate itself, and a record that changes its own history is worthless as evidence against an AED 3,000 fine.

9. **Refuse a `user.db` whose `user_version` exceeds `UserDatabase.understoodSchemaVersion`, and SAY SO.** Read `PRAGMA user_version` on a raw read-only handle before any Drift access; if higher, throw `UserDbFromTheFutureFailure(found: 5, understood: 4)` and render a plain screen naming both numbers. Never delete, never "repair". **WHY:** this is a downgrade — the user reinstalled an older build over a newer one — and letting Drift open it corrupts columns it cannot see, destroying the only copy of a log that has no cloud backup.

10. **`reference.db` lives in the SUPPORT directory, excluded from backup; `user.db` lives there and IS backed up.** `getApplicationSupportDirectory()/reference/` and `…/user/`, never `getTemporaryDirectory()` and never the OS cache dir. **WHY:** iOS evicts caches under storage pressure — the app would lose its entire rule set at sea with no way to refetch — and backing up a 40 MB regenerable asset burns the fisher's iCloud quota so the 200 KB file that actually matters stops syncing.

11. **No `ATTACH`, no cross-database JOIN, no shared `QueryExecutor`.** The rule engine receives plain Dart values read from `ReferenceDao`; a `Verdict` is composed in memory and written to `user.db` as literals. **WHY:** an `ATTACH` couples the two lifecycles back together — the wholesale swap in rule 4 must then invalidate live statements against the user DB, and the one guarantee this whole architecture buys is that it cannot.

## The split, in one file each

Two `@DriftDatabase` classes, two directories, two connection functions. The reference one has no migration surface at all; the user one is the only place `schemaVersion` ever moves.

```dart
// WRONG — one database, one schemaVersion, content and records fused forever.
@DriftDatabase(tables: [Species, Rules, Zones, Citations, Trips, Catches])
class CatchLawDatabase extends _$CatchLawDatabase {
  @override int get schemaVersion => 7;   // bumping this now rewrites the catch log
}

// RIGHT — content and record are separate files with separate lifecycles.
@DriftDatabase(tables: [Species, Zones, Rules, Citations, ContentMeta])
class ReferenceDatabase extends _$ReferenceDatabase {
  ReferenceDatabase(super.e);
  @override int get schemaVersion => 1;                 // frozen; never moves
  @override MigrationStrategy get migration => MigrationStrategy(
        onCreate: (_) async => throw StateError('reference.db is shipped, never created'),
        onUpgrade: (_, __, ___) async => throw StateError('reference.db is never migrated'),
      );
}

@DriftDatabase(tables: [Trips, Catches, Settings])
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.e);
  @override int get schemaVersion => 4;                 // forward-only, see `run-migration`
}
```

Full worked file: `examples/reference_database.dart`.

## Opening lazily, and never before `runApp`

`LazyDatabase` defers the whole open — directory lookup, extraction gate, `sqlite3_open` — to the first query, which happens after the first frame. The reference open is additionally `readOnly: true`.

```dart
// WRONG — a cold open on the critical path; ~700 ms of black screen on low-end Android.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = UserDatabase(await openUserConnection());   // awaited before the first frame
  await ReferenceInstaller().ensureInstalled();          // and 6 s on first launch
  runApp(ProviderScope(overrides: [userDbProvider.overrideWithValue(db)], child: const App()));
}

// RIGHT — synchronous main; every open is deferred into LazyDatabase.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CatchLawApp()));
}

QueryExecutor referenceExecutor() => LazyDatabase(() async {
      final file = await ReferenceInstaller().ensureInstalled();   // extraction gate lives here
      return NativeDatabase.createInBackground(file, readOnly: true);
    });
```

Full worked file: `examples/reference_database.dart`.

## The circular build-date check

You cannot ask the shipped asset which build it is without materialising it first. The build id therefore travels in two places that are both cheap to read: a sidecar asset and a generated constant.

```dart
// WRONG — circular: to read content_meta you must do the work you were trying to skip.
final db = ReferenceDatabase(NativeDatabase(await _extract()));   // 4 s, every launch
final installed = await db.select(db.contentMeta).getSingle();
if (installed.buildId != kReferenceBuildId) await _extract();     // extracts twice

// RIGHT — compare a 20-byte stamp on disk against a compile-time constant.
// lib/data/reference/reference_build.g.dart, emitted by the content tool:
//   const kReferenceBuildId = '2026.07.14+3';
//   const kReferenceBytes   = 41_582_592;
//   const kReferenceSha256  = 'b7c1…';
Future<File> ensureInstalled() async {
  final dir = Directory(p.join((await getApplicationSupportDirectory()).path, 'reference'));
  final stamp = File(p.join(dir.path, 'INSTALLED'));
  final db = File(p.join(dir.path, 'reference.db'));
  if (db.existsSync() && stamp.existsSync() &&
      stamp.readAsStringSync().trim() == kReferenceBuildId) {
    return db;                                            // ~2 ms, no decompression
  }
  return _extractFromAsset(dir, db, stamp);               // first launch, or after an update
}
```

Full worked file: `examples/reference_database.dart`.

## Temp file, atomic rename, orphan sweep

The only durable state transition is `rename`. Everything before it is disposable, and anything left behind is evidence of a kill, so it is swept on the next launch rather than trusted.

```dart
// WRONG — writes straight onto the live path; a kill at 80 % ships wrong minimum lengths.
Future<File> _extract(File db) async {
  final gz = await rootBundle.load('assets/db/reference.db.gz');
  await db.writeAsBytes(gzip.decode(gz.buffer.asUint8List()));   // truncated file opens fine
  return db;
}

// RIGHT — temp, verify, atomic rename, stamp last.
Future<File> _extractFromAsset(Directory dir, File db, File stamp) async {
  await dir.create(recursive: true);
  for (final f in dir.listSync().whereType<File>()) {
    if (f.path.endsWith('.tmp')) f.deleteSync();          // orphan sweep: a previous kill
  }
  if (stamp.existsSync()) stamp.deleteSync();             // stamp is invalid the moment we start
  final tmp = File('${db.path}.tmp');
  final sink = tmp.openWrite();
  await sink.addStream(_gunzipStream(onBytes: _report));  // determinate: kReferenceBytes
  await sink.flush();
  await sink.close();
  if (await _sha256(tmp) != kReferenceSha256) {
    tmp.deleteSync();
    throw const ReferencePayloadCorruptFailure();
  }
  await tmp.rename(db.path);                              // the ONE atomic step
  await stamp.writeAsString(kReferenceBuildId, flush: true);
  return db;
}
```

Full worked file: `examples/reference_database.dart`.

## Denormalising the judgment onto the catch row

A catch row is a legal record of what the app STATED at a moment in time. It stores the sentence's ingredients, not a pointer to a pack that will be replaced.

```dart
// WRONG — a foreign key into content; the record rewrites itself after an update.
class Catches extends Table {
  IntColumn get speciesId => integer()();                 // reference.db row, may be retired
  IntColumn get ruleId => integer()();                    // pack v2026.07 only
  IntColumn get measuredMm => integer()();
}

// RIGHT — everything the statement needs is copied onto the row, forever.
class Catches extends Table {
  TextColumn get id => text()();
  TextColumn get scientificName => text()();              // 'Epinephelus coioides'
  TextColumn get commonName => text()();                  // 'هامور  Hamour'
  IntColumn  get measuredMm => integer()();               // 380
  TextColumn get method => textEnum<MeasureMethod>()();   // TL / FL / CW / SHL
  TextColumn get verdict => textEnum<VerdictKind>()();    // meets / fails / stale
  TextColumn get statement => text()();                   // 'Below the minimum — 38 cm, minimum 45 cm (total length)'
  TextColumn get citationText => text()();                // 'Ministerial Decision 580/2015, Art. 3'
  DateTimeColumn get citationPublished => dateTime()();   // 2015-11-03
  DateTimeColumn get citationChecked => dateTime()();     // 2026-07-14
  TextColumn get contentVersion => text()();              // '2026.07.14+3'
  TextColumn get zoneId => text()();                      // 'ae-rak'  Ras Al Khaimah
  DateTimeColumn get judgedAt => dateTime()();
}
```

Full worked file: `examples/reference_database.dart`.

## Refusing a database from the future

A downgrade is the one case where opening is worse than failing. Read `PRAGMA user_version` on the raw handle first, then hand the file to Drift.

```dart
// WRONG — Drift opens it, sees a version it does not know, and writes into columns it cannot see.
QueryExecutor userExecutor() => LazyDatabase(() async =>
    NativeDatabase.createInBackground(await _userFile()));

// RIGHT — read the version on the raw handle, refuse plainly, never delete.
QueryExecutor userExecutor() => LazyDatabase(() async {
      final file = await _userFile();
      if (file.existsSync()) {
        final raw = sqlite3.open(file.path, mode: OpenMode.readOnly);
        final found = raw.select('PRAGMA user_version').first.columnAt(0) as int;
        raw.dispose();
        if (found > UserDatabase.understoodSchemaVersion) {
          throw UserDbFromTheFutureFailure(
            found: found, understood: UserDatabase.understoodSchemaVersion,
          );   // screen: 'This device holds records written by a newer version (5, this build reads 4).'
        }
      }
      return NativeDatabase.createInBackground(file);
    });
```

Full worked file: `examples/reference_database.dart`.

## Anti-patterns

- **`await database.ensureOpen()` above `runApp`** — moves a cold `sqlite3_open` onto the critical path and turns a 1.2 s cold start into a black screen.
- **`NativeDatabase(referenceFile)` without `readOnly: true`** — Drift may run `onCreate` against the shipped asset and drop a `-wal` beside it, breaking every later sha256 check.
- **`MigrationStrategy(onUpgrade: …)` on `ReferenceDatabase`** — declares that content is migratable, which invites `ALTER TABLE` on a file that is replaced wholesale anyway.
- **`SELECT build_id FROM content_meta` as the extraction gate** — circular: you must materialise 40 MB to decide whether to materialise 40 MB.
- **`db.writeAsBytes(gzip.decode(...))` onto the live path** — a kill mid-write leaves a truncated but openable file that answers with wrong minimum lengths.
- **`getTemporaryDirectory()` or the OS cache dir for `reference.db`** — iOS evicts it under storage pressure and the app loses its entire rule set offline, with no way to refetch.
- **`ATTACH DATABASE 'user.db' AS u`** — refuses the wholesale swap, because live statements now span both lifecycles.
- **`catches.speciesId` as a foreign key into `reference.db`** — a retired rule silently rewrites a three-year-old record's verdict.
- **Deleting or recreating a `user.db` with a higher `user_version`** — destroys the only copy of a log that has no cloud backup, to fix a downgrade the user can undo by updating.
- **`CircularProgressIndicator` over the first-launch extraction** — a six-second indeterminate spinner on a dark boat reads as a hang.
- **Bundling `reference.db` uncompressed** — triples the download and makes the byte-count-driven determinate bar impossible to calibrate.
- **`assert(referenceDb != null)` in `main()`** — smuggles an eager open past review because it disappears in release builds.

## Definition of done

- [ ] `scripts/check_reference_db.sh` is clean over `lib/`.
- [ ] `main()` contains no `await` on any database open, installer or executor; every open is inside a `LazyDatabase` callback (rule 2).
- [ ] `ReferenceDatabase` is opened with `readOnly: true` and its `MigrationStrategy` throws on both `onCreate` and `onUpgrade` (rules 3, 4).
- [ ] `kReferenceBuildId`, `kReferenceBytes` and `kReferenceSha256` are regenerated by the content tool and `assets/db/reference.build.json` is listed in `pubspec.yaml` assets (rule 5).
- [ ] The extraction path writes `*.tmp`, verifies sha256, calls `File.rename`, writes the `INSTALLED` stamp last, and sweeps orphan `*.tmp` before starting (rule 6).
- [ ] First launch shows a determinate bar driven by `kReferenceBytes`, completes under 6 s on the low-end reference device, and no spinner or "Loading…" string appears (rule 7).
- [ ] Every column the verdict statement needs is present on `catches` as a literal; no `catches` column references a `reference.db` row (rule 8).
- [ ] `PRAGMA user_version` is checked before Drift touches `user.db`, and a higher value throws `UserDbFromTheFutureFailure` with both numbers on screen (rule 9).
- [ ] `reference.db` sits under `getApplicationSupportDirectory()/reference/` excluded from backup; `user.db` sits under `…/user/` and is backed up (rule 10).
- [ ] No `ATTACH` statement and no `QueryExecutor` shared between the two databases exists anywhere in `lib/` (rule 11).

## Related skills

- See `persistence-drift` for Drift itself — `@DriftDatabase` wiring, DAO shape, transactions, keyset pagination and the generated `*.drift.dart` this skill only positions.
- See `run-migration` for the forward-only migration ritual, `schemaVersion` bumps and schema-dump tests that apply to `user.db` and are FORBIDDEN on `reference.db`.
- See `catchlaw-content-pipeline` for the CLI tool that builds `reference.db`, gzips it, and emits `reference.build.json` plus `reference_build.g.dart`.
- See `catchlaw-offline-guarantee` for the no-network invariant, the first-launch progress surface and the cold-start budget this extraction is carved out of.
- See `catchlaw-rule-engine` for the pure-Dart package that consumes reference rows as plain values and never imports Drift or Flutter.
- See `catchlaw-verdict-contract` for what the denormalised `statement`, `citationText` and `contentVersion` columns must contain and how a stale pack is still evaluated.
- See `app-startup-and-bootstrap` for the `main()` shape, binding initialisation and provider overrides that rule 2 constrains.
- See `error-handling-typed-results` for `Result` and the `Failure` hierarchy that `UserDbFromTheFutureFailure` and `ReferencePayloadCorruptFailure` belong to.
- See `catchlaw-conventions-index` for routing between the CatchLaw domain skills and the Lonja surface skills.

## References

- Drift — Getting started: https://drift.simonbinder.eu/docs/getting-started/
- Drift — Migrations: https://drift.simonbinder.eu/docs/advanced-features/migrations/
- SQLite — PRAGMA user_version: https://www.sqlite.org/pragma.html#pragma_user_version
- SQLite — ATTACH DATABASE: https://www.sqlite.org/lang_attach.html
- Dart API — File.rename: https://api.dart.dev/stable/dart-io/File/rename.html
- Dart API — GZipCodec: https://api.dart.dev/stable/dart-io/GZipCodec-class.html
- Flutter docs — Adding assets and images: https://docs.flutter.dev/ui/assets/assets-and-images
- pub.dev — path_provider: https://pub.dev/packages/path_provider
