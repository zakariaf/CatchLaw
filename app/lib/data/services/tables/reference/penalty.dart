import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `penalty`.
@DataClassName('PenaltyRow')
class Penalties extends Table {
  @override
  String get tableName => 'penalty';

  IntColumn get id => integer()();

  IntColumn get jurisdictionId =>
      integer().named('jurisdiction_id').customConstraint('NOT NULL REFERENCES jurisdiction(id)')();

  TextColumn get offenceKey => text().named('offence_key')();

  /// First, second or subsequent occurrence — instruments scale by it.
  IntColumn get occurrence => integer().withDefault(const Constant<int>(1))();

  IntColumn get amountMin => integer().named('amount_min').nullable()();

  IntColumn get amountMax => integer().named('amount_max').nullable()();

  /// Never converted: an instrument states a figure in one currency.
  TextColumn get currency => text().nullable()();

  /// Localised secondary consequence, e.g. a licence suspension.
  TextColumn get secondaryKey => text().named('secondary_key').nullable()();

  IntColumn get citationId =>
      integer().named('citation_id').customConstraint('NOT NULL REFERENCES citation(id)')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
