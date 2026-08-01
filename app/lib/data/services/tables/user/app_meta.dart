import 'package:drift/drift.dart';

/// `SPEC.md` §7.2 `app_meta`.
///
/// D-6 puts the extraction completion marker here as `content_build_date`,
/// rather than in the `INSTALLED` stamp file the skill's worked example uses.
/// **Two markers would be one too many, and the one that is not written last is
/// the one that lies.**
@DataClassName('AppMetaRow')
class AppMetas extends Table {
  @override
  String get tableName => 'app_meta';

  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};

  @override
  bool get isStrict => true;
}
