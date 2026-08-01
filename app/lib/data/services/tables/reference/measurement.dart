import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `measurement_method` — all nine codes.
///
/// TL and FL differ by 6–9 cm on a *Scomberomorus commerson*, which is why a
/// size never travels without one.
@DataClassName('MeasurementMethodRow')
class MeasurementMethods extends Table {
  @override
  String get tableName => 'measurement_method';

  IntColumn get id => integer()();

  /// `TL`, `FL`, `SL`, `CW`, `CL`, `ML`, `DW`, `SHL`, `CUSTOM`.
  TextColumn get code => text().unique()();

  TextColumn get nameKey => text().named('name_key')();

  /// Where on the fish the measurement starts and ends.
  TextColumn get definitionKey => text().named('definition_key')();

  /// Originated SVG. It does not mirror in RTL: a fork-length arrow must point
  /// at the actual fork.
  TextColumn get diagramAsset => text().named('diagram_asset')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
