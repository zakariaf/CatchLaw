// Demonstrates CatchLaw's two-database contract end to end: a synchronous main() that awaits
// nothing, a read-only LazyDatabase over the pre-seeded reference.db, a writable user.db that
// refuses a user_version from the future, the non-circular INSTALLED-stamp gate, an extraction
// that streams to a .tmp then verifies sha256 and atomically renames, and the denormalised
// `catches` columns a three-year-old record needs to restate itself after its rule was retired.
// Elided: the generated Drift parts, reference_build.g.dart, the reference-side tables,
// Trips/Settings and CatchLawApp. Conceptually compiles against drift 2.x, sqlite3, crypto,
// path_provider and path; every API used below is real.

import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

// ── Emitted by the content CLI into lib/data/reference/reference_build.g.dart ────────────────
const kReferenceBuildId = '2026.07.14+3';
const kReferenceBytes = 41582592;
const kReferenceSha256 = 'b7c1d9f2a4e60813c5ab2f77d0e1946355ca8b0f2d3e4471a9c8b6d5e4f30211';

// ── main(): nothing is awaited, nothing is opened ────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CatchLawApp());
}

// ── reference.db — content: read-only, never migrated, replaced wholesale ────────────────────
@DriftDatabase(tables: [Species, Zones, Rules, Citations, ContentMeta])
class ReferenceDatabase extends _$ReferenceDatabase {
  ReferenceDatabase(super.e);
  @override
  int get schemaVersion => 1; // frozen: this file is generated, not migrated

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (_) async => throw StateError('reference.db is shipped, never created'),
        onUpgrade: (_, __, ___) async => throw StateError('reference.db is never migrated'),
      );
}
QueryExecutor referenceExecutor() => LazyDatabase(() async {
      final file = await const ReferenceInstaller().ensureInstalled();
      return NativeDatabase.createInBackground(file, readOnly: true);
    });

// ── user.db — record: writable, migrated forward-only, irreplaceable ─────────────────────────
@DriftDatabase(tables: [Trips, Catches, Settings])
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.e);
  static const understoodSchemaVersion = 4;
  @override
  int get schemaVersion => understoodSchemaVersion; // steps live in `run-migration`
}
class UserDbFromTheFutureFailure implements Exception {
  const UserDbFromTheFutureFailure({required this.found, required this.understood});
  final int found, understood;
  @override
  String toString() => 'This device holds records written by a newer version of CatchLaw '
      '(schema $found; this build reads $understood).';
}
QueryExecutor userExecutor() => LazyDatabase(() async {
      final dir = Directory(p.join((await getApplicationSupportDirectory()).path, 'user'));
      await dir.create(recursive: true);
      final file = File(p.join(dir.path, 'user.db'));
      if (file.existsSync()) {
        // Read the version on a raw read-only handle BEFORE Drift touches columns it cannot see.
        final raw = sqlite3.open(file.path, mode: OpenMode.readOnly);
        final found = raw.select('PRAGMA user_version').first.columnAt(0) as int;
        raw.dispose();
        // Refuse plainly. Never delete, never "repair" — this is the only copy that exists.
        if (found > UserDatabase.understoodSchemaVersion) {
          throw UserDbFromTheFutureFailure(
              found: found, understood: UserDatabase.understoodSchemaVersion);
        }
      }
      return NativeDatabase.createInBackground(file);
    });

// ── The installer: a stamp on disk versus a constant in the binary ───────────────────────────
class ReferencePayloadCorruptFailure implements Exception {
  const ReferencePayloadCorruptFailure();
}
class ReferenceInstaller {
  const ReferenceInstaller({this.onProgress});
  final void Function(int done, int total)? onProgress;
  /// Extracts only when the on-disk stamp disagrees with [kReferenceBuildId]. NEVER opens the DB
  /// to decide: reading content_meta means materialising the 41 MB this gate exists to skip.
  Future<File> ensureInstalled() async {
    final dir = Directory(p.join((await getApplicationSupportDirectory()).path, 'reference'));
    final db = File(p.join(dir.path, 'reference.db'));
    final stamp = File(p.join(dir.path, 'INSTALLED'));
    final installed = stamp.existsSync() ? stamp.readAsStringSync().trim() : '';
    // ~2 ms: three stat calls and a 20-byte read. No decompression, no sqlite3_open.
    if (db.existsSync() && installed == kReferenceBuildId) return db;
    return _extract(dir, db, stamp);
  }

  Future<File> _extract(Directory dir, File db, File stamp) async {
    await dir.create(recursive: true);
    // Sweep orphans first: a *.tmp here is residue from a kill mid-extraction.
    for (final f in dir.listSync().whereType<File>()) {
      if (f.path.endsWith('.tmp')) f.deleteSync();
    }
    // Drop the stamp BEFORE writing, so a kill can never leave a claim about an unverified file.
    if (stamp.existsSync()) stamp.deleteSync();
    final tmp = File('${db.path}.tmp');
    final sink = tmp.openWrite();
    var done = 0;
    try {
      final gz = await rootBundle.load('assets/db/reference.db.gz');
      await for (final chunk
          in gzip.decoder.bind(Stream<List<int>>.value(gz.buffer.asUint8List()))) {
        sink.add(chunk);
        done += chunk.length;
        // Determinate: the denominator is the sidecar's byte count, never a guess.
        if (done % 65536 < chunk.length) onProgress?.call(done, kReferenceBytes);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    final digest = await sha256.bind(tmp.openRead()).first;
    if (digest.toString() != kReferenceSha256 || tmp.lengthSync() != kReferenceBytes) {
      tmp.deleteSync();
      throw const ReferencePayloadCorruptFailure();
    }
    await tmp.rename(db.path); // the ONE atomic step: old file or new file, never half
    await stamp.writeAsString(kReferenceBuildId, flush: true); // stamped last
    return db;
  }
}

// ── The record: every ingredient of the statement, copied as a literal ──────────────────────
enum MeasureMethod { tl, fl, cw, shl } // total, fork, carapace width, shell length
enum VerdictKind { meets, fails, stale }
class Catches extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)(); // stays within user.db
  TextColumn get scientificName => text()(); // 'Epinephelus coioides'
  TextColumn get commonName => text()(); // 'هامور  Hamour'
  IntColumn get measuredMm => integer()(); // 380
  TextColumn get method => textEnum<MeasureMethod>()(); // TL / FL / CW / SHL
  TextColumn get verdict => textEnum<VerdictKind>()(); // fails
  // The exact words shown — a statement of fact, never an instruction:
  // 'Below the minimum — 38 cm, minimum 45 cm (total length)'
  TextColumn get statement => text()();
  TextColumn get citationText => text()(); // 'Ministerial Decision 580/2015, Art. 3'
  DateTimeColumn get citationPublished => dateTime()(); // 2015-11-03
  DateTimeColumn get citationChecked => dateTime()(); // 2026-07-14
  TextColumn get contentVersion => text()(); // '2026.07.14+3'
  TextColumn get zoneId => text()(); // 'ae-rak' — Ras Al Khaimah
  DateTimeColumn get judgedAt => dateTime()();
  // NO foreign key into reference.db: a retired rule must not rewrite a 2023 record.
  @override
  Set<Column> get primaryKey => {id};
}
