import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `content_meta` — `schema_version`, `build_date` and
/// `generator_commit`.
///
/// Written by the content build from its own `--build-date` and
/// `--generator-commit`, never authored: a hand-written value would let the file
/// disagree with the run that produced it, and `generator_commit` is how a stale
/// database is traced back to the tree that wrote it.
@DataClassName('ContentMetaRow')
class ContentMetas extends Table {
  @override
  String get tableName => 'content_meta';

  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
