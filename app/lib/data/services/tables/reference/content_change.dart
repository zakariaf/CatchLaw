import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `content_change` — what S23 tells the reader changed.
///
/// §4.7 promises the user can see currency. A change with no row here breaks
/// that promise silently, which is what A10 exists to stop.
@DataClassName('ContentChangeRow')
class ContentChanges extends Table {
  @override
  String get tableName => 'content_change';

  IntColumn get id => integer()();

  IntColumn get jurisdictionId =>
      integer().named('jurisdiction_id').customConstraint('NOT NULL REFERENCES jurisdiction(id)')();

  TextColumn get fromVersion => text().named('from_version')();

  TextColumn get toVersion => text().named('to_version')();

  TextColumn get summaryKey => text().named('summary_key')();

  TextColumn get detailKey => text().named('detail_key').nullable()();

  TextColumn get changedOn => text().named('changed_on')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
