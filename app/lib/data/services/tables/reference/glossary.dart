import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `glossary_term` — S22's rows.
@DataClassName('GlossaryTermRow')
class GlossaryTerms extends Table {
  @override
  String get tableName => 'glossary_term';

  IntColumn get id => integer()();

  /// `null` means the term is global.
  IntColumn get jurisdictionId => integer()
      .named('jurisdiction_id')
      .nullable()
      .customConstraint('REFERENCES jurisdiction(id)')();

  TextColumn get termKey => text().named('term_key')();

  TextColumn get definitionKey => text().named('definition_key')();

  IntColumn get sortOrder => integer().named('sort_order').withDefault(const Constant<int>(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
