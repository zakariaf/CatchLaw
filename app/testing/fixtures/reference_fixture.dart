import 'dart:io';

import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

/// An in-memory rule book with the schema created by drift.
///
/// The schema-SHAPE seam only. A DAO test must use [openBuiltReference]: drift's
/// `Table` classes and `tools/content_builder/`'s DDL are two descriptions of
/// one schema, and a test that reads the same description it wrote proves
/// nothing about the file that ships.
ReferenceDatabase inMemoryReference() => ReferenceDatabase.forTesting(NativeDatabase.memory());

/// The **real** `reference.db` that `tools/content_builder/` produced.
///
/// Copied to a temporary directory first, so a test that somehow writes cannot
/// touch the committed artefact, and so the `-wal`/`-shm` assertions are about
/// files this test created rather than about whatever is beside the original.
Future<(ReferenceDatabase, File)> openBuiltReference() async {
  final Directory dir = Directory.systemTemp.createTempSync('catchlaw_reference_');
  final File copy = builtReferenceFile().copySync(p.join(dir.path, 'reference.db'));
  return (ReferenceDatabase(referenceExecutor(copy)), copy);
}

/// `app/assets/db/reference.db`, as the content build wrote it.
///
/// Git-ignored — the `.gz` is what ships (D-6) — so a clone that has not run the
/// build has no file here, and the tests that need it say so rather than
/// silently passing over nothing.
File builtReferenceFile() => File(p.join(_appRoot(), 'assets', 'db', 'reference.db'));

/// Whether the built file exists, so a test can skip with a reason rather than
/// fail for the wrong one.
bool builtReferenceExists() => builtReferenceFile().existsSync();

String _appRoot() {
  // `flutter test` runs with the package directory as its working directory.
  final Directory here = Directory.current;
  return p.basename(here.path) == 'app' ? here.path : p.join(here.path, 'app');
}
