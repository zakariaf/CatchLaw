import 'dart:io';
import 'package:catchlaw/data/services/tables/reference/citation.dart';
import 'package:catchlaw/data/services/tables/reference/content_change.dart';
import 'package:catchlaw/data/services/tables/reference/content_meta.dart';
import 'package:catchlaw/data/services/tables/reference/content_string.dart';
import 'package:catchlaw/data/services/tables/reference/gear.dart';
import 'package:catchlaw/data/services/tables/reference/glossary.dart';
import 'package:catchlaw/data/services/tables/reference/jurisdiction.dart';
import 'package:catchlaw/data/services/tables/reference/key.dart';
import 'package:catchlaw/data/services/tables/reference/legal_text.dart';
import 'package:catchlaw/data/services/tables/reference/licence.dart';
import 'package:catchlaw/data/services/tables/reference/measurement.dart';
import 'package:catchlaw/data/services/tables/reference/penalty.dart';
import 'package:catchlaw/data/services/tables/reference/rule.dart';
import 'package:catchlaw/data/services/tables/reference/taxonomy.dart';
import 'package:catchlaw/data/services/tables/reference/zone.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

part 'reference_database_service.g.dart';

/// The read-only rule book: every `SPEC.md` §7.1 table.
///
/// **`schemaVersion` is frozen at 1 and both migration callbacks throw.**
/// `reference.db` is generated, not evolved — §7.4 calls it "shipped whole and
/// disposable". An incrementally patched reference database has no single
/// provenance, so `catch.content_version` stops being able to name the pack that
/// produced a verdict, and a three-year-old catch record stops being able to say
/// what it said when it was recorded. Throwing callbacks make that
/// unrepresentable rather than merely discouraged.
///
/// **Opened `readOnly: true`, and that is a correctness requirement.** Open it
/// writable and drift is entitled to run `onCreate` against shipped content and
/// to leave a `-wal` beside it. From that moment the file's sha256 no longer
/// matches the sidecar, so the extraction integrity check reports a corrupt
/// payload on a database that is fine — and every later launch re-extracts ten
/// megabytes to fix a problem the open created.
@DriftDatabase(
  tables: <Type>[
    Jurisdictions,
    Zones,
    ZoneRings,
    Families,
    SpeciesTable,
    SpeciesNames,
    MeasurementMethods,
    Citations,
    Rules,
    ClosedSeasons,
    LicenceTypes,
    GearRules,
    Penalties,
    Lookalikes,
    GlossaryTerms,
    ContentChanges,
    KeyNodes,
    KeyLeafSpecies,
    KeyOptions,
    ContentStrings,
    LegalTexts,
    ContentMetas,
  ],
  include: <String>{'tables/reference/legal_text_fts.drift'},
)
class ReferenceDatabase extends _$ReferenceDatabase {
  /// Opens the shipped rule book over [executor].
  ReferenceDatabase(super.executor) : _allowSchemaBuild = false;

  /// An in-memory database whose schema drift builds for itself.
  ///
  /// The **one** seam where that is allowed, and the reason it is fenced: it is
  /// a second description of a schema whose authority is `SPEC.md` §7.1 and
  /// whose producer is `tools/content_builder/`. Nothing forces the two to
  /// agree, so the DAO tests of T07 read a **real built file** and only the
  /// schema-shape tests use this one.
  @visibleForTesting
  factory ReferenceDatabase.forTesting(QueryExecutor executor) =>
      ReferenceDatabase._seeded(executor);

  ReferenceDatabase._seeded(super.executor) : _allowSchemaBuild = true;

  /// Whether this instance is the [ReferenceDatabase.forTesting] seam.
  ///
  /// `false` on every instance the app constructs, which is what makes the
  /// throwing `onCreate` below unavoidable in production.
  final bool _allowSchemaBuild;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      if (_allowSchemaBuild) return m.createAll();
      throw StateError(
        'reference.db is shipped whole and disposable (SPEC.md §7.4). Creating '
        'it here would give it no single provenance, and catch.content_version '
        'could no longer name the pack that produced a verdict.',
      );
    },
    onUpgrade: (Migrator m, int from, int to) async => throw StateError(
      'reference.db is replaced, never migrated: an ALTER TABLE against shipped '
      'content leaves a file no build can reproduce. Ship a new pack instead '
      '(attempted $from -> $to).',
    ),
  );
}

/// A [LazyDatabase] over the extracted rule book at [file].
///
/// `LazyDatabase` because `FLUTTER_GUIDE.md` §5.2 forbids awaiting a database
/// open before `runApp`: the connection is established on first query, on a
/// background isolate, and the first frame does not wait for it.
///
/// **`NativeDatabase.opened` over an `OpenMode.readOnly` handle, not
/// `createInBackground` — D-16.** `catchlaw-reference-database`'s worked example
/// and `FLUTTER_GUIDE.md` §5.2 both write
/// `NativeDatabase.createInBackground(file, readOnly: true, …)`, and drift
/// 2.34.2 has no such parameter on that constructor. The alternative available
/// there is a writable file handle guarded by `PRAGMA query_only`, which is a
/// promise rather than a protection: the OS would still permit the write that
/// leaves a `-wal` beside the file and breaks every later sha256 check. D-6's
/// integrity guarantee rests on the handle, so the handle is what is read-only.
///
/// The cost is named: the open runs on the calling isolate rather than a
/// background one. `LazyDatabase` still defers it to the first **query**, so
/// nothing is awaited before `runApp` — which is the property §5.2 is actually
/// protecting.
///
/// The pragmas are the two that do not write. `persistence-drift` sets
/// `journal_mode = WAL`, `synchronous = FULL` and `foreign_keys = ON` on every
/// open; three of those are writes. `foreign_keys` is deliberately left off — it
/// governs DML, there is none here, and enabling it buys nothing on a connection
/// that cannot write.
QueryExecutor referenceExecutor(File file) => referenceExecutorAt(() async => file);

/// The same read-only open, over a file that is not known yet.
///
/// [locate] runs inside the [LazyDatabase] callback — on the first query, after
/// the first frame — so the composition root can wire this database without
/// awaiting `path_provider`'s platform channel before `runApp`.
QueryExecutor referenceExecutorAt(Future<File> Function() locate) => LazyDatabase(
  () async => NativeDatabase.opened(
    sqlite3.open((await locate()).path, mode: OpenMode.readOnly)
      ..execute('PRAGMA query_only = 1;')
      ..execute('PRAGMA busy_timeout = 5000;'),
    // reference.db is shipped whole and disposable: drift must not run a
    // migration against it, and closeUnderlyingOnClose keeps the handle's
    // lifetime tied to this database's.
    enableMigrations: false,
    closeUnderlyingOnClose: true,
  ),
);
